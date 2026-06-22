# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryEnclosureAssignmentRepository
        include Domain::Repositories::EnclosureAssignmentRepository
        include Snapshotable

        def initialize(assignments = [])
          @store = []
          assignments.each { |assignment| save(assignment) }
        end

        def save(event)
          @store << event
          event
        end

        def all
          @store.dup
        end

        def enclosures_of(keeper)
          current_assignments.select { |assignment| assignment.keeper_id.to_s == keeper.id.to_s }
                             .map(&:enclosure)
                             .uniq(&:id)
        end

        def assignment_of(keeper, enclosure)
          current_assignments.find do |assignment|
            assignment.keeper_id.to_s == keeper.id.to_s && assignment.enclosure_id.to_s == enclosure.id.to_s
          end
        end

        private

        def current_assignments
          closed = @store.grep(Domain::EnclosureDischarge).map { |discharge| discharge.assignment.id.to_s }
          @store.select { |event| event.is_a?(Domain::EnclosureAssignment) && !closed.include?(event.id.to_s) }
        end
      end
    end
  end
end
