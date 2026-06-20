# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class BirthMapper
        Domain = Zoo::Domain

        def to_row(birth)
          {
            id: birth.id.to_s,
            sire_id: birth.sire.id.to_s,
            dam_id: birth.dam.id.to_s,
            offspring_id: birth.offspring.id.to_s,
            day: birth.day,
            season: birth.season.value.to_s
          }
        end

        def to_aggregate(row, lookup)
          sire = lookup.call(Domain::Shared::Identifier.new(row['sire_id']))
          dam = lookup.call(Domain::Shared::Identifier.new(row['dam_id']))
          offspring = lookup.call(Domain::Shared::Identifier.new(row['offspring_id']))
          return nil unless sire && dam && offspring

          Domain::Birth.reconstitute(
            id: Domain::Shared::Identifier.new(row['id']),
            sire: sire, dam: dam, offspring: offspring,
            day: row['day'], season: Domain::Season.new(row['season'])
          )
        end
      end
    end
  end
end
