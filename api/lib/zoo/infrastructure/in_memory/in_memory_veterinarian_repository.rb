# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryVeterinarianRepository
        include Domain::Repositories::VeterinarianRepository
        include Snapshotable

        def initialize(veterinarians = [])
          @store = {}
          veterinarians.each { |vet| save(vet) }
        end

        def find(id)
          @store[id.to_s]
        end

        def save(veterinarian)
          @store[veterinarian.id.to_s] = veterinarian
          veterinarian
        end

        def all
          @store.values
        end
      end
    end
  end
end
