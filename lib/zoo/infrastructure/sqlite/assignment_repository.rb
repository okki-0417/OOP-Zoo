# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class AssignmentRepository
        include Domain::Repositories::AssignmentRepository

        def initialize(database, keepers, enclosures,
                       tending_mapper: TendingMapper.new, relieving_mapper: RelievingMapper.new)
          @database = database
          @keepers = keepers
          @enclosures = enclosures
          @tending_mapper = tending_mapper
          @relieving_mapper = relieving_mapper
        end

        def save(event)
          if event.is_a?(Domain::Relieving)
            relievings.insert(@relieving_mapper.to_row(event))
          else
            tendings.insert(@tending_mapper.to_row(event))
          end
          event
        end

        def all
          built = build_tendings(tendings.order(:seq).all)
          built + build_relievings(relievings.order(:seq).all, by_id(built))
        end

        def enclosures_of(keeper)
          active_tendings.select { |tending| tending.keeper_id.to_s == keeper.id.to_s }
                         .map(&:enclosure)
                         .uniq(&:id)
        end

        def active_tending_of(keeper, enclosure)
          active_tendings.find do |tending|
            tending.keeper_id.to_s == keeper.id.to_s && tending.enclosure_id.to_s == enclosure.id.to_s
          end
        end

        def keepers_of(enclosure)
          active_tendings.select { |tending| tending.enclosure_id.to_s == enclosure.id.to_s }
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

        def active_tendings
          build_tendings(tendings.exclude(id: relievings.select(:tending_id)).order(:seq).all)
        end

        def by_id(built)
          built.to_h { |tending| [tending.id.to_s, tending] }
        end

        def build_tendings(rows)
          rows = rows.map { |row| row.transform_keys(&:to_s) }
          keeper_lookup = keeper_lookup(rows)
          enclosure_lookup = enclosure_lookup(rows)
          rows.filter_map { |row| @tending_mapper.to_aggregate(row, keeper_lookup, enclosure_lookup) }
        end

        def build_relievings(rows, tendings_by_id)
          rows.filter_map do |row|
            @relieving_mapper.to_aggregate(row.transform_keys(&:to_s), tendings_by_id)
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
