# frozen_string_literal: true

module Zoo
  module Application
    class EventDispatcher
      def initialize(event_store:, subscribers: [])
        @event_store = event_store
        @subscribers = subscribers
      end

      def publish(events)
        events.each do |event|
          @event_store.append(event)
          @subscribers.each { |subscriber| subscriber.handle(event) }
        end
      end
    end
  end
end
