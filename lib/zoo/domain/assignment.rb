# frozen_string_literal: true

module Zoo
  module Domain
    class Assignment
      attr_reader :tending, :relieving

      def initialize(tending, relieving = nil)
        @tending = tending
        @relieving = relieving
      end

      def keeper
        @tending.keeper
      end

      def enclosure
        @tending.enclosure
      end

      def keeper_id
        @tending.keeper_id
      end

      def enclosure_id
        @tending.enclosure_id
      end

      def assigned_on
        @tending.occurred_on
      end

      def relieved_on
        @relieving&.occurred_on
      end

      def active?
        @relieving.nil?
      end

      def relieved?
        !active?
      end

      def to_s
        "#{keeper.name}を#{enclosure.name}に配属"
      end
    end
  end
end
