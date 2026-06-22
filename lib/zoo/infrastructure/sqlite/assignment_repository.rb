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

        def save(event)
          if event.is_a?(Domain::Relieving)
            relievings.insert(@mapper.relieving_row(event))
          else
            tendings.insert(@mapper.tending_row(event))
          end
          event
        end

        def all
          assignments
        end

        def enclosures_of(keeper)
          active_assignments.select { |assignment| assignment.keeper_id.to_s == keeper.id.to_s }
                            .map(&:enclosure)
                            .uniq(&:id)
        end

        def active_assignment_of(keeper, enclosure)
          active_assignments.find do |assignment|
            assignment.keeper_id.to_s == keeper.id.to_s && assignment.enclosure_id.to_s == enclosure.id.to_s
          end
        end

        def keepers_of(enclosure)
          active_assignments.select { |assignment| assignment.enclosure_id.to_s == enclosure.id.to_s }
                            .map(&:keeper)
                            .uniq(&:id)
        end

        private

        def tendings
          @database.dataset(:tendings)
        end

        def relievings
          @database.dataset(:relievings)
        end

        def assignments
          built = build_tendings(tendings.order(:seq).all)
          by_id = built.to_h { |tending| [tending.id.to_s, tending] }
          relieved = build_relievings(relievings.order(:seq).all, by_id)
          built.map { |tending| Domain::Assignment.new(tending, relieved[tending.id.to_s]) }
        end

        def active_assignments
          assignments.select(&:active?)
        end

        def build_tendings(rows)
          rows = rows.map { |row| row.transform_keys(&:to_s) }
          keeper_lookup = keeper_lookup(rows)
          enclosure_lookup = enclosure_lookup(rows)
          rows.filter_map { |row| @mapper.to_tending(row, keeper_lookup, enclosure_lookup) }
        end

        def build_relievings(rows, tendings_by_id)
          rows.each_with_object({}) do |row, found|
            row = row.transform_keys(&:to_s)
            relieving = @mapper.to_relieving(row, tendings_by_id)
            found[relieving.tending.id.to_s] = relieving if relieving
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
