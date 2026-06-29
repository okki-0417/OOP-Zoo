# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class ZooReport
        def initialize(enclosures:, housings:, zoo:, animals:, births:)
          @enclosures = enclosures
          @housings = housings
          @zoo = zoo
          @animals = animals
          @births = births
        end

        def call
          occupants = @housings.all_occupants
          species = occupants.map(&:species).uniq
          zoo = @zoo.load

          ReadModels::ZooStatistics.new(
            population: occupants.size,
            species_count: species.size,
            threatened_count: species.count(&:threatened?),
            births: @births.all.size,
            deaths_by_cause: deaths_by_cause,
            revenue: zoo.revenue,
            balance: zoo.balance,
            reputation: zoo.reputation_score
          )
        end

        private

        def deaths_by_cause
          @animals.all_deceased
                  .group_by(&:cause_of_death)
                  .transform_values(&:size)
        end
      end
    end
  end
end
