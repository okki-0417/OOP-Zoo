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

        def events_for_enclosure(enclosure_id)
          id = enclosure_id.to_s
          housing_ids = @store.select { |event| housed_in?(event, id) }.map { |event| event.id.to_s }
          @store.select do |event|
            housed_in?(event, id) ||
              (event.is_a?(Domain::Release) && housing_ids.include?(event.housing.id.to_s))
          end
        end

        def current_housing_of(animal)
          Domain::Occupancy.new(@store).current_housing_of(animal)
        end

        private

        def housed_in?(event, enclosure_id)
          event.is_a?(Domain::Housing) && event.enclosure_id.to_s == enclosure_id
        end
      end
    end
  end
end
