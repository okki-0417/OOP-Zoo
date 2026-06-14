# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryAnimalRepository
        include Domain::Repositories::AnimalRepository
        include Snapshotable

        def initialize(animals = [])
          @store = {}
          animals.each { |animal| save(animal) }
        end

        def find(id)
          @store[id.to_s]
        end

        def save(animal)
          @store[animal.id.to_s] = animal
          animal
        end

        def all
          @store.values
        end
      end
    end
  end
end
