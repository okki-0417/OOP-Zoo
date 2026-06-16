# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class ZooReport
        def initialize(enclosures:, event_store:, zoo:)
          @enclosures = enclosures
          @event_store = event_store
          @zoo = zoo
        end

        def call
          occupants = @enclosures.all.flat_map(&:occupants)
          species = occupants.map(&:species).uniq
          events = @event_store.all
          zoo = @zoo.load

          ReadModels::ZooStatistics.new(
            population: occupants.size,
            species_count: species.size,
            threatened_count: species.count { |s| s.conservation_status.threatened? },
            births: events.count { |event| event.is_a?(Domain::Events::AnimalBorn) },
            deaths_by_cause: deaths_by_cause(events),
            revenue: zoo.revenue,
            balance: zoo.balance,
            reputation: zoo.reputation.score
          )
        end

        private

        def deaths_by_cause(events)
          events.select { |event| event.is_a?(Domain::Events::AnimalDied) }
                .group_by(&:cause)
                .transform_values(&:size)
        end
      end
    end
  end
end
