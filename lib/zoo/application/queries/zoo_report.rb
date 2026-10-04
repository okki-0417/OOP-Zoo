# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class ZooReport
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:zoo_report) do
            occupants = @command.housings.all_occupants
            species = occupants.map(&:species).uniq
            zoo = @command.zoo.load
            ReadModels::ZooStatistics.new(
              population: occupants.size,
              species_count: species.size,
              threatened_count: species.count(&:threatened?),
              births: @command.births.all.size,
              deaths_by_cause: deaths_by_cause,
              revenue: zoo.revenue,
              balance: zoo.balance,
              reputation: zoo.reputation_score
            )
          end
        end

        private

        def deaths_by_cause
          @command.animals.all_deceased
                  .group_by(&:cause_of_death)
                  .transform_values(&:size)
        end
      end
    end
  end
end
