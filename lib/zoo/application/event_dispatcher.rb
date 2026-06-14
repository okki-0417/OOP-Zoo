# frozen_string_literal: true

module Zoo
  module Application
    # イベントの唯一の publish 先。EventStore へ永続化し、購読者へ通知する。
    # ユースケースは EventStore も購読者も直接知らず、本ハブに publish するだけ。
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
