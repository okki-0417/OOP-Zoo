# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryAnimalRepository
        include Domain::Repositories::AnimalRepository

        def initialize(animals = [])
          @store = {}
          @births = []
          @conceptions = []
          @namings = []
          animals.each { |animal| save(animal) }
        end

        def find(id)
          @store[id.to_s]
        end

        def save(animal)
          @store[animal.id.to_s] = animal
          @births.concat(animal.recorded_events.grep(Domain::Events::Birth))
          @conceptions.concat(animal.recorded_events.grep(Domain::Events::AnimalConceived))
          @namings.concat(animal.recorded_events.grep(Domain::Events::AnimalNamed))
          animal
        end

        def all
          @store.values
        end

        def births
          @births.dup
        end

        def conceptions
          @conceptions.dup
        end

        def namings
          @namings.dup
        end

        def snapshot
          [@store.dup, @births.dup, @conceptions.dup, @namings.dup]
        end

        def restore(snapshot)
          @store, @births, @conceptions, @namings = snapshot
        end
      end
    end
  end
end
