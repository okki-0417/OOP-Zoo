# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Subscribers
      class BirthAnnouncementLog
        include Application::EventSubscriber

        def initialize
          @announcements = []
        end

        def handle(event)
          return unless event.is_a?(Domain::Events::Birth)

          @announcements << event.to_s
        end

        def announcements
          @announcements.dup
        end
      end
    end
  end
end
