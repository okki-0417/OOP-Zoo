# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryAnimalRepository
        include Domain::Repositories::AnimalRepository

        def initialize(animals = [])
          @store = {}
          @namings = []
          animals.each { |animal| save(animal) }
        end

        def find(id)
          @store[id.to_s]
        end

        def find_all(ids)
          ids.map(&:to_s).uniq.each_with_object({}) do |id, found|
            animal = @store[id]
            found[id] = animal if animal
          end
        end

        def save(animal)
          @store[animal.id.to_s] = animal
          @namings.concat(animal.recorded_events.grep(Domain::Events::AnimalNamed))
          animal
        end

        def all
          @store.values
        end

        def namings
          @namings.dup
        end

        def snapshot
          [@store.dup, @namings.dup]
        end

        def restore(snapshot)
          @store, @namings = snapshot
        end
      end
    end
  end
end
