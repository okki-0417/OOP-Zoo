# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class TendingRepository
        include Domain::Repositories::TendingRepository

        TENDING = TendingMapper::TENDING
        RELIEVING = TendingMapper::RELIEVING

        def initialize(database, keepers, enclosures, mapper: TendingMapper.new)
          @database = database
          @keepers = keepers
          @enclosures = enclosures
          @mapper = mapper
        end

        def save(event)
          tendings.insert(@mapper.to_row(event))
          event
        end

        def all
          build_events(tendings.order(:seq).all)
        end

        def enclosures_of(keeper)
          build_events(current_tendings.where(keeper_id: keeper.id.to_s).order(:seq).all)
            .map(&:enclosure)
            .uniq(&:id)
        end

        def tending_of(keeper, enclosure)
          build_events(
            current_tendings.where(keeper_id: keeper.id.to_s, enclosure_id: enclosure.id.to_s).order(:seq).all
          ).first
        end

        def keepers_of(enclosure)
          build_events(current_tendings.where(enclosure_id: enclosure.id.to_s).order(:seq).all)
            .map(&:keeper)
            .uniq(&:id)
        end

        private

        def tendings
          @database.dataset(:tendings)
        end

        def current_tendings
          relieved = tendings.where(kind: RELIEVING)
                             .exclude(closes_tending_id: nil)
                             .select(:closes_tending_id)
          tendings.where(kind: TENDING).exclude(id: relieved)
        end

        def build_events(rows)
          rows = rows.map { |row| row.transform_keys(&:to_s) }
          keeper_lookup = keeper_lookup(rows)
          enclosure_lookup = enclosure_lookup(rows)
          built = {}
          rows.filter_map do |row|
            event = @mapper.to_aggregate(row, keeper_lookup, enclosure_lookup, built)
            built[event.id.to_s] = event if event.is_a?(Domain::Tending)
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
