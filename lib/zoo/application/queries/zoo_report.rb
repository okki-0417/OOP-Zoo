# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class ZooReport
        def initialize(enclosures:, housings:, event_store:, zoo:, animals:, births:)
          @enclosures = enclosures
          @housings = housings
          @event_store = event_store
          @zoo = zoo
          @animals = animals
          @births = births
        end

        def call
          occupants = @housings.all_occupants
          species = occupants.map(&:species).uniq
          events = @event_store.all
          zoo = @zoo.load

          ReadModels::ZooStatistics.new(
            population: occupants.size,
            species_count: species.size,
            threatened_count: species.count { |s| s.conservation_status.threatened? },
            births: @births.all.size,
            deaths_by_cause: deaths_by_cause(events),
            revenue: zoo.revenue,
            balance: zoo.balance,
            reputation: zoo.reputation.score
          )
        end

        private

        def deaths_by_cause(events)
          events.grep(Domain::Events::AnimalDied)
                .group_by(&:cause)
                .transform_values(&:size)
        end
      end
    end
  end
end
