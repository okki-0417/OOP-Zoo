# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class HousingMapper
        Domain = Zoo::Domain

        HOUSED = 'housed'
        RELEASED = 'released'

        def to_row(event)
          event.is_a?(Domain::Release) ? release_row(event) : housing_row(event)
        end

        def to_aggregate(row, animal_lookup, enclosure_lookup, housings)
          row['kind'] == RELEASED ? released(row, housings) : housed(row, animal_lookup, enclosure_lookup)
        end

        private

        def housing_row(housing)
          {
            id: housing.id.to_s,
            animal_id: housing.animal.id.to_s,
            enclosure_id: housing.enclosure_id.to_s,
            kind: HOUSED,
            occurred_on: housing.occurred_on,
            keeper_id: housing.keeper_id&.to_s,
            closes_housing_id: nil
          }
        end

        def release_row(release)
          {
            id: release.id.to_s,
            animal_id: release.animal.id.to_s,
            enclosure_id: nil,
            kind: RELEASED,
            occurred_on: release.occurred_on,
            keeper_id: release.keeper_id&.to_s,
            closes_housing_id: release.housing.id.to_s
          }
        end

        def housed(row, animal_lookup, enclosure_lookup)
          animal = animal_lookup.call(Domain::Shared::Identifier.new(row['animal_id']))
          enclosure = enclosure_lookup.call(Domain::Shared::Identifier.new(row['enclosure_id']))
          return nil unless animal && enclosure

          Domain::Housing.new(
            id: Domain::Shared::Identifier.new(row['id']),
            animal: animal,
            enclosure: enclosure,
            occurred_on: row['occurred_on'],
            keeper_id: keeper_id(row)
          )
        end

        def released(row, housings)
          housing = housings[row['closes_housing_id']]
          return nil unless housing

          Domain::Release.new(
            id: Domain::Shared::Identifier.new(row['id']),
            housing: housing,
            occurred_on: row['occurred_on'],
            keeper_id: keeper_id(row)
          )
        end

        def keeper_id(row)
          row['keeper_id'] && Domain::Shared::Identifier.new(row['keeper_id'])
        end
      end
    end
  end
end
