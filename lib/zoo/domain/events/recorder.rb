# frozen_string_literal: true

module Zoo
  module Domain
    module Events
      # ドメインイベントを記録する集約向けのmixin。
      #
      # 集約は状態変化が起きたときに record_event でイベントを溜め、
      # アプリケーション側は pull_events で取り出して購読者へ配信する
      # (取り出すと内部のバッファは空になる)。
      module Recorder
        def record_event(event)
          recorded_events << event
          event
        end

        def recorded_events
          @recorded_events ||= []
        end

        # 溜まったイベントを取り出してバッファを空にする。
        def pull_events
          events = recorded_events.dup
          recorded_events.clear
          events
        end
      end
    end
  end
end
