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
        def initialize(open_for_a_day:, enclosures:, animals:, keepers:, veterinarians:, zoo:, unit_of_work:)
          @open_for_a_day = open_for_a_day
          @enclosures = enclosures
          @animals = animals
          @keepers = keepers
          @veterinarians = veterinarians
          @zoo = zoo
          @unit_of_work = unit_of_work
        end

        def call
          @unit_of_work.run do
            dead = @open_for_a_day.call
            zoo = @zoo.load

            visitors = Domain::Operations::VisitorAttraction.expected_visitors(on_exhibit, zoo.reputation)
            income = zoo.admission_fee * visitors
            zoo.admit_visitors(visitors)

            cost = Domain::Operations::OperatingCost.daily(
              enclosures: @enclosures.all.size, animals: @animals.all.size, staff: staff_count
            )
            zoo.spend(cost)

            zoo.apply_reputation(Domain::Operations::ReputationPolicy.after_day(zoo.reputation, deaths: dead.size))
            @zoo.save(zoo)

            ReadModels::DayReport.new(
              visitors: visitors, income: income, cost: cost, deaths: dead.size,
              balance: zoo.balance, reputation: zoo.reputation.score, bankrupt: zoo.bankrupt?
            )
          end
        end

        private

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
