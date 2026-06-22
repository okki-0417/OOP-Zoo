# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class EnclosureAssignmentMapper
        Domain = Zoo::Domain

        ASSIGNED = 'assigned'
        DISCHARGED = 'discharged'

        def to_row(event)
          event.is_a?(Domain::EnclosureDischarge) ? discharge_row(event) : assignment_row(event)
        end

        def to_aggregate(row, keeper_lookup, enclosure_lookup, assignments)
          if row['kind'] == DISCHARGED
            discharged(row, assignments)
          else
            assigned(row, keeper_lookup, enclosure_lookup)
          end
        end

        private

        def assignment_row(assignment)
          {
            id: assignment.id.to_s,
            keeper_id: assignment.keeper_id.to_s,
            enclosure_id: assignment.enclosure_id.to_s,
            kind: ASSIGNED,
            occurred_on: assignment.occurred_on,
            closes_enclosure_assignment_id: nil
          }
        end

        def discharge_row(discharge)
          {
            id: discharge.id.to_s,
            keeper_id: nil,
            enclosure_id: nil,
            kind: DISCHARGED,
            occurred_on: discharge.occurred_on,
            closes_enclosure_assignment_id: discharge.assignment.id.to_s
          }
        end

        def assigned(row, keeper_lookup, enclosure_lookup)
          keeper = keeper_lookup.call(Domain::Shared::Identifier.new(row['keeper_id']))
          enclosure = enclosure_lookup.call(Domain::Shared::Identifier.new(row['enclosure_id']))
          return nil unless keeper && enclosure

          Domain::EnclosureAssignment.new(
            id: Domain::Shared::Identifier.new(row['id']),
            keeper: keeper,
            enclosure: enclosure,
            occurred_on: row['occurred_on']
          )
        end

        def discharged(row, assignments)
          assignment = assignments[row['closes_enclosure_assignment_id']]
          return nil unless assignment

          Domain::EnclosureDischarge.of(
            assignment, occurred_on: row['occurred_on'], id: Domain::Shared::Identifier.new(row['id'])
          )
        end
      end
    end
  end
end
