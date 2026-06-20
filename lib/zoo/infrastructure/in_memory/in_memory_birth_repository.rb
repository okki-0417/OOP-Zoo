# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryBirthRepository
        include Domain::Repositories::BirthRepository

        def initialize(births = [])
          @store = {}
          births.each { |birth| save(birth) }
        end

        def save(birth)
          @store[birth.id.to_s] = birth
          birth
        end

        def all
          @store.values
        end

        DEFAULT_MAX_DEPTH = 20

        def ancestry(*animals, max_depth: DEFAULT_MAX_DEPTH)
          by_offspring = @store.values.to_h { |birth| [birth.offspring.id.to_s, birth] }
          collected = {}
          frontier = animals.map { |animal| animal.id.to_s }
          depth = 0
          until frontier.empty? || depth >= max_depth
            frontier = expand(frontier, by_offspring, collected)
            depth += 1
          end
          collected.values
        end

        def snapshot
          @store.dup
        end

        def restore(snapshot)
          @store = snapshot
        end

        private

        def expand(frontier, by_offspring, collected)
          frontier.flat_map do |id|
            birth = by_offspring[id]
            next [] if birth.nil? || collected.key?(birth.id.to_s)

            collected[birth.id.to_s] = birth
            [birth.sire.id.to_s, birth.dam.id.to_s]
          end
        end
      end
    end
  end
end
