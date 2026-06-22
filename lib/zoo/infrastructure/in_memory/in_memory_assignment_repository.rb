# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryAssignmentRepository
        include Domain::Repositories::AssignmentRepository
        include Snapshotable

        def initialize(assignments = [])
          @store = {}
          assignments.each { |assignment| save(assignment) }
        end

        def save(assignment)
          @store[assignment.id.to_s] = assignment
          assignment
        end

        def all
          @store.values
        end

        def enclosures_of(keeper)
          active.select { |assignment| assignment.keeper_id.to_s == keeper.id.to_s }
                .map(&:enclosure)
                .uniq(&:id)
        end

        def active_assignment_of(keeper, enclosure)
          active.find do |assignment|
            assignment.keeper_id.to_s == keeper.id.to_s && assignment.enclosure_id.to_s == enclosure.id.to_s
          end
        end

        def keepers_of(enclosure)
          active.select { |assignment| assignment.enclosure_id.to_s == enclosure.id.to_s }
                .map(&:keeper)
                .uniq(&:id)
        end

        private

        def active
          @store.values.select(&:active?)
        end
      end
    end
  end
end
