# frozen_string_literal: true

module Services
  class RunDays
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:run_days) do
        dead = Array.new(@command.days) { operate_day.casualties }.flatten

        {
          days: @command.days,
          total_deaths: dead.size,
          deaths_by_cause: dead.group_by(&:cause_of_death).transform_values(&:size)
        }
      end
    end

    private

    def operate_day
      result = OperateDay.new(command: @command.operate_day_command).call
      raise result.error if result.failure?

      result.value
    end
  end
end
