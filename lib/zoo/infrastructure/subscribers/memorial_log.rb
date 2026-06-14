# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Subscribers
      class MemorialLog
        include Application::EventSubscriber

        def initialize
          @entries = []
        end

        def handle(event)
          return unless event.is_a?(Domain::Events::AnimalDied)

          @entries << event.to_s
        end

        def entries
          @entries.dup
        end
      end
    end
  end
end
