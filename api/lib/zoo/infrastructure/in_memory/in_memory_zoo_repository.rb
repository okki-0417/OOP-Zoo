# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryZooRepository
        include Domain::Repositories::ZooRepository

        def initialize(zoo)
          @zoo = zoo
        end

        def load
          @zoo
        end

        def save(zoo)
          @zoo = zoo
        end
      end
    end
  end
end
