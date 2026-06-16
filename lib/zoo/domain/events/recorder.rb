# frozen_string_literal: true

module Zoo
  module Domain
    module Events
      module Recorder
        def record_event(event)
          recorded_events << event
          event
        end

        def recorded_events
          @recorded_events ||= []
        end

        def pull_events
          events = recorded_events.dup
          recorded_events.clear
          events
        end
      end
    end
  end
end
