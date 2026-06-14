# frozen_string_literal: true

module Zoo
  module Application
    module Services
      # 1日の運営ループを束ねる高階のユースケース。
      #
      # 加齢・死亡(OpenForADay)を回し、展示内容と評判から来園者を集めて収益を得、
      # 運営費を支払い、その日の結果で評判を更新する。式はドメインサービスが持ち、
      # 本サービスはそれらの調整に徹する。
      class OperateDay
        def initialize(open_for_a_day:, enclosures:, animals:, keepers:, veterinarians:, zoo:, unit_of_work:,
                       random: Random.new)
          @open_for_a_day = open_for_a_day
          @enclosures = enclosures
          @animals = animals
          @keepers = keepers
          @veterinarians = veterinarians
          @zoo = zoo
          @unit_of_work = unit_of_work
          @random = random
        end

        def call
          @unit_of_work.run do
            zoo = @zoo.load
            dead = @open_for_a_day.call(season: zoo.season)

            visitors = Domain::Operations::VisitorAttraction.expected_visitors(
              on_exhibit, zoo.reputation, zoo.admission_fee
            )
            income = zoo.admission_fee * visitors
            zoo.admit_visitors(visitors)

            cost = Domain::Operations::OperatingCost.daily(
              enclosures: @enclosures.all.size, animals: @animals.all.size, staff: staff_count
            )
            zoo.spend(cost)

            outbreak = strike_outbreak

            zoo.apply_reputation(Domain::Operations::ReputationPolicy.after_day(zoo.reputation, deaths: dead.size))
            zoo.advance_day
            @zoo.save(zoo)

            ReadModels::DayReport.new(
              visitors: visitors, income: income, cost: cost, deaths: dead.size,
              balance: zoo.balance, reputation: zoo.reputation.score, bankrupt: zoo.bankrupt?,
              outbreak: outbreak
            )
          end
        end

        private

        # 疫病が発生したら1頭を発病させ、その名前を返す(無ければ nil)。
        def strike_outbreak
          afflicted = Domain::Operations::OutbreakPolicy.strike(on_exhibit, @random)
          return nil if afflicted.nil?

          afflicted.fall_ill(Domain::Medical::IllnessCatalog.parasite)
          @animals.save(afflicted)
          afflicted.name.to_s
        end

        def on_exhibit
          @enclosures.all.flat_map(&:occupants)
        end

        def staff_count
          @keepers.all.size + @veterinarians.all.size
        end
      end
    end
  end
end
