# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class TendingMapper
        Domain = Zoo::Domain

        TENDING = 'tending'
        RELIEVING = 'relieving'

        def to_row(event)
          event.is_a?(Domain::Relieving) ? relieving_row(event) : tending_row(event)
        end

        def to_aggregate(row, keeper_lookup, enclosure_lookup, tendings)
          if row['kind'] == RELIEVING
            relieving(row, tendings)
          else
            tending(row, keeper_lookup, enclosure_lookup)
          end
        end

        private

        def tending_row(tending)
          {
            id: tending.id.to_s,
            keeper_id: tending.keeper_id.to_s,
            enclosure_id: tending.enclosure_id.to_s,
            kind: TENDING,
            occurred_on: tending.occurred_on,
            closes_tending_id: nil
          }
        end

        def relieving_row(relieving)
          {
            id: relieving.id.to_s,
            keeper_id: nil,
            enclosure_id: nil,
            kind: RELIEVING,
            occurred_on: relieving.occurred_on,
            closes_tending_id: relieving.tending.id.to_s
          }
        end

        def tending(row, keeper_lookup, enclosure_lookup)
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

        def relieving(row, tendings)
          tending = tendings[row['closes_tending_id']]
          return nil unless tending

          Domain::Relieving.of(
            tending, occurred_on: row['occurred_on'], id: Domain::Shared::Identifier.new(row['id'])
          )
        end
      end
    end
  end
end
