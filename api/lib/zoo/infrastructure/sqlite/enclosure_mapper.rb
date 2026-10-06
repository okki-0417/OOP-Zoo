# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class EnclosureMapper
        def to_row(enclosure)
          {
            id: enclosure.id.to_s,
            name: enclosure.name,
            celsius: enclosure.temperature.celsius,
            capacity: enclosure.capacity,
            cleanliness: enclosure.cleanliness.level,
            enrichment: enclosure.enrichment.level,
            climate_controlled: enclosure.climate_controlled? ? 1 : 0
          }
        end

        def to_aggregate(row)
          Domain::Enclosure.reconstitute(
            id: Domain::Shared::Identifier.new(row['id']),
            name: row['name'],
            temperature: Domain::Shared::Temperature.celsius(row['celsius']),
            capacity: row['capacity'],
            cleanliness: Domain::Enclosure::Cleanliness.new(row['cleanliness']),
            enrichment: Domain::Enclosure::Enrichment.new(row['enrichment']),
            climate_controlled: row['climate_controlled'] == 1
          )
        end
      end
    end
  end
end
