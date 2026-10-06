# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryKeeperRepository
        include Domain::Repositories::KeeperRepository
        include Snapshotable

        def initialize(keepers = [])
          @store = {}
          keepers.each { |keeper| save(keeper) }
        end

        def find(id)
          @store[id.to_s]
        end

        def save(keeper)
          @store[keeper.id.to_s] = keeper
          keeper
        end

        def all
          @store.values
        end
      end
    end
  end
end
