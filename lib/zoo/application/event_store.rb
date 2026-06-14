# frozen_string_literal: true

module Zoo
  module Application
    module EventStore
      def append(_event)
        raise NotImplementedError, "#{self.class}#append を実装してください"
      end

      def all
        raise NotImplementedError, "#{self.class}#all を実装してください"
      end
    end
  end
end
