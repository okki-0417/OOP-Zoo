# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryEnclosureRepository
        include Domain::Repositories::EnclosureRepository
        include Snapshotable

        def initialize(enclosures = [])
          @store = {}
          enclosures.each { |enclosure| save(enclosure) }
        end

        def find(id)
          @store[id.to_s]
        end

        def find_all(ids)
          ids.map(&:to_s).uniq.each_with_object({}) do |id, found|
            enclosure = @store[id]
            found[id] = enclosure if enclosure
          end
        end

        def save(enclosure)
          @store[enclosure.id.to_s] = enclosure
          enclosure
        end

        def all
          @store.values
        end
      end
    end
  end
end
