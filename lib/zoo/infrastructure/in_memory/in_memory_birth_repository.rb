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

        def snapshot
          @store.dup
        end

        def restore(snapshot)
          @store = snapshot
        end
      end
    end
  end
end
