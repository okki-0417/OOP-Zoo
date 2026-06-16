# frozen_string_literal: true

module Zoo
  module Application
    module Services
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
