# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class BreedingMapper
        Domain = Zoo::Domain

        def to_row(breeding)
          {
            id: breeding.id.to_s,
            sire_id: breeding.sire.id.to_s,
            dam_id: breeding.dam.id.to_s,
            day: breeding.day,
            season: breeding.season.value.to_s
          }
        end

        def to_aggregate(row, lookup)
          sire = lookup.call(Domain::Shared::Identifier.new(row['sire_id']))
          dam = lookup.call(Domain::Shared::Identifier.new(row['dam_id']))
          return nil unless sire && dam

          Domain::Breeding.new(
            sire: sire, dam: dam,
            day: row['day'], season: Domain::Season.new(row['season']),
            id: Domain::Shared::Identifier.new(row['id'])
          )
        end
      end
    end
  end
end
