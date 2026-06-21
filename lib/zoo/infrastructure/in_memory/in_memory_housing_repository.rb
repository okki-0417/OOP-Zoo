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
      end
    end
  end
end
