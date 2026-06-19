# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class BirthMapper
        Domain = Zoo::Domain

        def to_row(birth)
          {
            sire_id: birth.sire_id.to_s,
            dam_id: birth.dam_id.to_s,
            offspring_id: birth.offspring.id.to_s,
            occurred_on: birth.occurred_on,
            season: birth.season.value.to_s
          }
        end

        def to_aggregate(row, lookup)
          offspring = lookup.call(Domain::Shared::Identifier.new(row['offspring_id']))
          return nil unless offspring

          Domain::Events::Birth.new(
            offspring: offspring,
            sire_id: Domain::Shared::Identifier.new(row['sire_id']),
            dam_id: Domain::Shared::Identifier.new(row['dam_id']),
            occurred_on: row['occurred_on'],
            season: Domain::Season.new(row['season'])
          )
        end
      end
    end
  end
end
