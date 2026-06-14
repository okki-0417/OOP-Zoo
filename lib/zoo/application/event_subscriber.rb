# frozen_string_literal: true

module Zoo
  module Application
    module EventSubscriber
      def handle(_event)
        raise NotImplementedError, "#{self.class}#handle を実装してください"
      end
    end
  end
end
