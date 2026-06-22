# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class AssignmentRepository
        include Domain::Repositories::AssignmentRepository

        def initialize(database, keepers, enclosures, mapper: AssignmentMapper.new)
          @database = database
          @keepers = keepers
          @enclosures = enclosures
          @mapper = mapper
        end

        def save(assignment)
          row = @mapper.to_row(assignment)
          existing = assignments.where(id: assignment.id.to_s)
          existing.empty? ? assignments.insert(row) : existing.update(row)
          assignment
        end

        def all
          build_events(assignments.order(:seq).all)
        end

        def enclosures_of(keeper)
          build_events(active.where(keeper_id: keeper.id.to_s).order(:seq).all)
            .map(&:enclosure)
            .uniq(&:id)
        end

        def active_assignment_of(keeper, enclosure)
          build_events(
            active.where(keeper_id: keeper.id.to_s, enclosure_id: enclosure.id.to_s).order(:seq).all
          ).first
        end

        def keepers_of(enclosure)
          build_events(active.where(enclosure_id: enclosure.id.to_s).order(:seq).all)
            .map(&:keeper)
            .uniq(&:id)
        end

        private

        def assignments
          @database.dataset(:assignments)
        end

        def active
          assignments.where(relieved: 0)
        end

        def build_events(rows)
          rows = rows.map { |row| row.transform_keys(&:to_s) }
          keeper_lookup = keeper_lookup(rows)
          enclosure_lookup = enclosure_lookup(rows)
          rows.filter_map { |row| @mapper.to_aggregate(row, keeper_lookup, enclosure_lookup) }
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
