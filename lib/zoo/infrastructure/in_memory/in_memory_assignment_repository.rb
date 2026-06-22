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

        def assignments
          relievings = @store.grep(Domain::Relieving).to_h { |relieving| [relieving.tending.id.to_s, relieving] }
          @store.grep(Domain::Tending).map { |tending| Domain::Assignment.new(tending, relievings[tending.id.to_s]) }
        end

        def active_assignments
          assignments.select(&:active?)
        end
      end
    end
  end
end
