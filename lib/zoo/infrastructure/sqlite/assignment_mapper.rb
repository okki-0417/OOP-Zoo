# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class AssignmentMapper
        Domain = Zoo::Domain

        def tending_row(tending)
          {
            id: tending.id.to_s,
            keeper_id: tending.keeper_id.to_s,
            enclosure_id: tending.enclosure_id.to_s,
            occurred_on: tending.occurred_on
          }
        end

        def relieving_row(relieving)
          {
            id: relieving.id.to_s,
            tending_id: relieving.tending.id.to_s,
            occurred_on: relieving.occurred_on
          }
        end

        def to_tending(row, keeper_lookup, enclosure_lookup)
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

        def to_relieving(row, tendings_by_id)
          tending = tendings_by_id[row['tending_id']]
          return nil unless tending

          Domain::Relieving.of(
            tending, occurred_on: row['occurred_on'], id: Domain::Shared::Identifier.new(row['id'])
          )
        end
      end
    end
  end
end
