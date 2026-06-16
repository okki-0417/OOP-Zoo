# frozen_string_literal: true

module Zoo
  module Application
    module Services
      # 1日の運営を実行するユースケース。
      #
      # 加齢・死亡(OpenForADay)を回し、1日のサイクル(DailyOperation ドメインサービス)に
      # 編成を委ねる。本サービスはトランザクション境界・永続化・read model への変換に徹する
      # (「何が起きるか」はドメイン、「いつ回して保存するか」はここ)。
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

            outcome = Domain::Operations::DailyOperation.run(
              zoo: zoo, enclosures: @enclosures.all, animals: @animals.all,
              dead: dead, staff_count: staff_count, random: @random
            )

            @animals.save(outcome.afflicted) if outcome.afflicted
            @zoo.save(zoo)

            ReadModels::DayReport.new(
              visitors: outcome.visitors, income: outcome.income, cost: outcome.cost, deaths: outcome.deaths,
              balance: zoo.balance, reputation: zoo.reputation.score, bankrupt: zoo.bankrupt?,
              outbreak: outcome.outbreak_name
            )
          end
        end

        private

        def staff_count
          @keepers.all.size + @veterinarians.all.size
        end
      end
    end
  end
end
