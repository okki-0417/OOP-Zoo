# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryAssignmentRepository
        include Domain::Repositories::AssignmentRepository
        include Snapshotable

        def initialize(events = [])
          @store = []
          events.each { |event| save(event) }
        end

        def save(event)
          @store << event
          event
        end

        def all
          @store.dup
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

        def active_tendings
          relieved = @store.grep(Domain::Relieving).map { |relieving| relieving.tending.id.to_s }
          @store.grep(Domain::Tending).reject { |tending| relieved.include?(tending.id.to_s) }
        end
      end
    end
  end
end
