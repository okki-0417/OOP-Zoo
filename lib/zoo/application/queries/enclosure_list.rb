# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class EnclosureList
        def initialize(enclosures:)
          @enclosures = enclosures
        end

        def call
          @enclosures.all.map do |enclosure|
            ReadModels::EnclosureSummary.new(
              id: enclosure.id.to_s,
              name: enclosure.name,
              population: enclosure.population,
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
