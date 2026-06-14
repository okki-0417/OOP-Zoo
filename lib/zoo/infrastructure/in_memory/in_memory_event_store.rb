# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryEventStore
        include Application::EventStore

        def initialize
          @events = []
        end

        def append(event)
          @events << event
          event
        end

        def all
          @events.dup
        end
      end
    end
  end
end
