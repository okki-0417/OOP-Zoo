# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class TendingMapper
        Domain = Zoo::Domain

        def to_row(tending)
          {
            id: tending.id.to_s,
            keeper_id: tending.keeper_id.to_s,
            enclosure_id: tending.enclosure_id.to_s,
            occurred_on: tending.occurred_on
          }
        end

        def to_aggregate(row, keeper_lookup, enclosure_lookup)
          keeper = keeper_lookup.call(Domain::Shared::Identifier.new(row['keeper_id']))
          enclosure = enclosure_lookup.call(Domain::Shared::Identifier.new(row['enclosure_id']))
          return nil unless keeper && enclosure

          Domain::Tending.new(
            id: Domain::Shared::Identifier.new(row['id']),
            keeper: keeper,
            enclosure: enclosure,
            occurred_on: row['occurred_on']
          )
        end
      end
    end
  end
end
