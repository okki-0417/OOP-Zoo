# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class RelievingMapper
        Domain = Zoo::Domain

        def to_row(relieving)
          {
            id: relieving.id.to_s,
            tending_id: relieving.tending.id.to_s,
            occurred_on: relieving.occurred_on
          }
        end

        def to_aggregate(row, tendings_by_id)
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
