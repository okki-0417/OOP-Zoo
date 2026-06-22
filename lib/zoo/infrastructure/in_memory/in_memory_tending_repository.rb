# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryTendingRepository
        include Domain::Repositories::TendingRepository
        include Snapshotable

        def initialize(tendings = [])
          @store = []
          tendings.each { |tending| save(tending) }
        end

        def save(event)
          @store << event
          event
        end

        def all
          @store.dup
        end

        def enclosures_of(keeper)
          current_tendings.select { |tending| tending.keeper_id.to_s == keeper.id.to_s }
                          .map(&:enclosure)
                          .uniq(&:id)
        end

        def tending_of(keeper, enclosure)
          current_tendings.find do |tending|
            tending.keeper_id.to_s == keeper.id.to_s && tending.enclosure_id.to_s == enclosure.id.to_s
          end
        end

        def keepers_of(enclosure)
          current_tendings.select { |tending| tending.enclosure_id.to_s == enclosure.id.to_s }
                          .map(&:keeper)
                          .uniq(&:id)
        end

        private

        def current_tendings
          relieved = @store.grep(Domain::Relieving).map { |relieving| relieving.tending.id.to_s }
          @store.select { |event| event.is_a?(Domain::Tending) && !relieved.include?(event.id.to_s) }
        end
      end
    end
  end
end
