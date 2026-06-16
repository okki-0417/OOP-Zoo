# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class Action
        def initialize(container:)
          @container = container
        end

        def call(_params)
          raise NotImplementedError, "#{self.class}#call を実装してください"
        end
      end
    end
  end
end
