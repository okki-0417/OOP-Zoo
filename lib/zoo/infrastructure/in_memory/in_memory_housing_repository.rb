# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryHousingRepository
        include Domain::Repositories::HousingRepository
        include Snapshotable

        def initialize(housings = [])
          @store = []
          housings.each { |housing| save(housing) }
        end

        def save(housing)
          @store << housing
          housing
        end

        def all
          @store.dup
        end

        def current_housing_of(animal)
          current_housings[animal.id.to_s]
        end

        def occupants_of(enclosure)
          current_housings.values
                          .select { |housing| housing.enclosure_id.to_s == enclosure.id.to_s && housing.animal.alive? }
                          .map(&:animal)
        end

        def all_occupants
          current_housings.values.filter_map { |housing| housing.animal if housing.animal.alive? }
        end

        private

        def current_housings
          closed = @store.grep(Domain::Releasing).map { |release| release.housing.id.to_s }
          @store.each_with_object({}) do |event, current|
            next unless event.is_a?(Domain::Housing) && !closed.include?(event.id.to_s)

            current[event.animal.id.to_s] = event
          end
        end
      end
    end
  end
end
