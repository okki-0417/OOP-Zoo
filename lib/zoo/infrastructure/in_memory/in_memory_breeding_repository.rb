# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryBreedingRepository
        include Domain::Repositories::BreedingRepository

        def initialize(breedings = [])
          @store = {}
          breedings.each { |breeding| save(breeding) }
        end

        def save(breeding)
          @store[breeding.id.to_s] = breeding
          breeding
        end

        def all
          @store.values
        end

        def for_dam(dam_id)
          @store.values.select { |breeding| breeding.dam.id.to_s == dam_id.to_s }.last
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
