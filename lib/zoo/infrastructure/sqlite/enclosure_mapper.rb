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
            occupant_ids: enclosure.occupants.map { |animal| animal.id.to_s }.join(',')
          }
        end

        def to_aggregate(row, occupants)
          Domain::Enclosure.reconstitute(
            id: Domain::Shared::Identifier.new(row['id']),
            name: row['name'],
            temperature: Domain::Shared::Temperature.celsius(row['celsius']),
            capacity: row['capacity'],
            cleanliness: Domain::Enclosure::Cleanliness.new(row['cleanliness']),
            occupants: occupants
          )
        end

        def occupant_ids(row)
          row['occupant_ids'].to_s.split(',').reject(&:empty?)
        end
      end
    end
  end
end
