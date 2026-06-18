# frozen_string_literal: true

module Zoo
  module Domain
    class Enrichment
      include Shared::ValueObject
      include Comparable

      MIN = 0
      MAX = 100
      BARREN_THRESHOLD = 30

      attr_reader :level

      def self.stimulating
        new(MAX)
      end

      def initialize(level)
        raise ArgumentError, '刺激度は整数でなければなりません' unless level.is_a?(Integer)

        @level = level.clamp(MIN, MAX)
        freeze
      end

      def depleted_by(amount)
        raise ArgumentError, '減衰量は0以上でなければなりません' if amount.negative?

        self.class.new(@level - amount)
      end

      def enriched_by(amount)
        raise ArgumentError, '補充量は0以上でなければなりません' if amount.negative?

        self.class.new(@level + amount)
      end

      def barren?
        @level <= BARREN_THRESHOLD
      end

      def <=>(other)
        return nil unless other.is_a?(Enrichment)

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
