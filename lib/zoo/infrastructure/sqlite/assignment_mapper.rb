# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class AssignmentMapper
        Domain = Zoo::Domain

        def to_row(assignment)
          {
            id: assignment.id.to_s,
            keeper_id: assignment.keeper_id.to_s,
            enclosure_id: assignment.enclosure_id.to_s,
            relieved: assignment.relieved? ? 1 : 0,
            occurred_on: assignment.occurred_on
          }
        end

        def to_aggregate(row, keeper_lookup, enclosure_lookup)
          keeper = keeper_lookup.call(Domain::Shared::Identifier.new(row['keeper_id']))
          enclosure = enclosure_lookup.call(Domain::Shared::Identifier.new(row['enclosure_id']))
          return nil unless keeper && enclosure

          Domain::Assignment.new(
            id: Domain::Shared::Identifier.new(row['id']),
            keeper: keeper,
            enclosure: enclosure,
            relieved: row['relieved'].to_i == 1,
            occurred_on: row['occurred_on']
          )
        end
      end
    end
  end
end
