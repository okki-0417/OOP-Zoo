# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryOperatingRepository
        include Domain::Repositories::OperatingRepository

        def initialize(operatings = [])
          @store = {}
          operatings.each { |operating| save(operating) }
        end

        def save(operating)
          @store[operating.id.to_s] = operating
          operating
        end

        def all
          @store.values.sort_by(&:day)
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
