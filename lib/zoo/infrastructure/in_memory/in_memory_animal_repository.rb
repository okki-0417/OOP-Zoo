# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryAnimalRepository
        include Domain::Repositories::AnimalRepository

        def initialize(animals = [])
          @store = {}
          @births = []
          animals.each { |animal| save(animal) }
        end

        def find(id)
          @store[id.to_s]
        end

        def save(animal)
          @store[animal.id.to_s] = animal
          @births.concat(animal.recorded_events.grep(Domain::Events::Birth))
          animal
        end

        def all
          @store.values
        end

        def births
          @births.dup
        end

        def snapshot
          [@store.dup, @births.dup]
        end

        def restore(snapshot)
          @store, @births = snapshot
        end
      end
    end
  end
end
