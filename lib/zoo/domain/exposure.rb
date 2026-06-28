# frozen_string_literal: true

module Zoo
  module Domain
    class Exposure
      def initialize(visitors:)
        @visitors = visitors
      end

      def score
        @visitors
      end
    end
  end
end
