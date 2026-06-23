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
          @enclosures.all.map do |enclosure|
            ReadModels::EnclosureSummary.new(
              id: enclosure.id.to_s,
              name: enclosure.name,
              population: @housings.occupants_of(enclosure).size,
              capacity: enclosure.capacity,
              cleanliness: enclosure.cleanliness_level,
              filthy: enclosure.filthy?
            )
          end
        end
      end
    end
  end
end
