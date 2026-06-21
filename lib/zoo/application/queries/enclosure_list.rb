# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class EnclosureList
        def initialize(enclosures:, housings:)
          @enclosures = enclosures
          @housings = housings
        end

        def call
          occupancy = Domain::Occupancy.new(@housings.all)
          @enclosures.all.map do |enclosure|
            ReadModels::EnclosureSummary.new(
              id: enclosure.id.to_s,
              name: enclosure.name,
              population: occupancy.population_of(enclosure),
              capacity: enclosure.capacity,
              cleanliness: enclosure.cleanliness.level,
              filthy: enclosure.filthy?
            )
          end
        end
      end
    end
  end
end
