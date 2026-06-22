# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class EnclosureAssignmentRepository
        include Domain::Repositories::EnclosureAssignmentRepository

        ASSIGNED = EnclosureAssignmentMapper::ASSIGNED
        DISCHARGED = EnclosureAssignmentMapper::DISCHARGED

        def initialize(database, keepers, enclosures, mapper: EnclosureAssignmentMapper.new)
          @database = database
          @keepers = keepers
          @enclosures = enclosures
          @mapper = mapper
        end

        def save(event)
          assignments.insert(@mapper.to_row(event))
          event
        end

        def all
          build_events(assignments.order(:seq).all)
        end

        def enclosures_of(keeper)
          build_events(current_assignments.where(keeper_id: keeper.id.to_s).order(:seq).all)
            .map(&:enclosure)
            .uniq(&:id)
        end

        def assignment_of(keeper, enclosure)
          build_events(
            current_assignments.where(keeper_id: keeper.id.to_s, enclosure_id: enclosure.id.to_s).order(:seq).all
          ).first
        end

        private

        def assignments
          @database.dataset(:enclosure_assignments)
        end

        def current_assignments
          closed = assignments.where(kind: DISCHARGED)
                              .exclude(closes_enclosure_assignment_id: nil)
                              .select(:closes_enclosure_assignment_id)
          assignments.where(kind: ASSIGNED).exclude(id: closed)
        end

        def build_events(rows)
          rows = rows.map { |row| row.transform_keys(&:to_s) }
          keeper_lookup = keeper_lookup(rows)
          enclosure_lookup = enclosure_lookup(rows)
          built = {}
          rows.filter_map do |row|
            event = @mapper.to_aggregate(row, keeper_lookup, enclosure_lookup, built)
            built[event.id.to_s] = event if event.is_a?(Domain::EnclosureAssignment)
            event
          end
        end

        def keeper_lookup(rows)
          ids = rows.filter_map { |row| row['keeper_id'] }.uniq
          keepers = ids.each_with_object({}) do |id, found|
            keeper = @keepers.find(Domain::Shared::Identifier.new(id))
            found[id] = keeper if keeper
          end
          ->(id) { keepers[id.to_s] }
        end

        def enclosure_lookup(rows)
          enclosures = @enclosures.find_all(rows.filter_map { |row| row['enclosure_id'] })
          ->(id) { enclosures[id.to_s] }
        end
      end
    end
  end
end
