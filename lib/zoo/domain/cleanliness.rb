# frozen_string_literal: true

module Zoo
  module Domain
    class Cleanliness
      include Shared::ValueObject
      include Comparable

      MIN = 0
      MAX = 100
      FILTHY_THRESHOLD = 30

      attr_reader :level

      def self.spotless
        new(MAX)
      end

      def initialize(level)
        raise ArgumentError, '清潔度は整数でなければなりません' unless level.is_a?(Integer)

        @level = level.clamp(MIN, MAX)
        freeze
      end

      def soiled_by(amount)
        raise ArgumentError, '汚れ量は0以上でなければなりません' if amount.negative?

        self.class.new(@level - amount)
      end

      def cleaned_by(amount)
        raise ArgumentError, '清掃量は0以上でなければなりません' if amount.negative?

        self.class.new(@level + amount)
      end

      def filthy?
        @level <= FILTHY_THRESHOLD
      end

      def <=>(other)
        return nil unless other.is_a?(Cleanliness)

        @level <=> other.level
      end

      def to_s
        "#{@level}/#{MAX}"
      end

      protected

      def components
        [@level]
      end
    end
  end
end
