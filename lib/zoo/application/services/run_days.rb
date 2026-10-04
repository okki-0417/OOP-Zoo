# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class RunDays
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:run_days) do
            dead = Array.new(@command.days) { deaths_of_a_day }.flatten

            ReadModels::RunDaysSummary.new(
              days: @command.days,
              total_deaths: dead.size,
              deaths_by_cause: dead.group_by(&:cause_of_death).transform_values(&:size)
            )
          end
        end

        private

        def deaths_of_a_day
          result = open_for_a_day.call
          raise result.error if result.failure?

          result.value
        end

        def open_for_a_day
          OpenForADay.new(
            command: Commands::OpenForADayCommand.new.bind(
              enclosures: @command.enclosures, animals: @command.animals,
              housings: @command.housings, unit_of_work: @command.unit_of_work
            )
          )
        end
      end
    end
  end
end
