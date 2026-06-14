# frozen_string_literal: true

module Zoo
  module Application
    module Services
      # OpenForADay を複数日まわし、死亡を集計した推移サマリを返す高階のユースケース。
      # 新しいルールは持たず、既存ユースケースの合成だけを担う。
      class RunDays
        def initialize(open_for_a_day:)
          @open_for_a_day = open_for_a_day
        end

        def call(command)
          dead = []
          command.days.times { dead.concat(@open_for_a_day.call) }

          ReadModels::RunDaysSummary.new(
            days: command.days,
            total_deaths: dead.size,
            deaths_by_cause: dead.group_by { |animal| animal.death.cause }.transform_values(&:size)
          )
        end
      end
    end
  end
end
