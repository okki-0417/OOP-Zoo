# frozen_string_literal: true

module Zoo
  module Domain
    class Reputation
      include Shared::ValueObject
      include Comparable

      MIN = 0
      MAX = 100

      DRIFT_CAP = 3
      DOWN_MULTIPLIER = 2
      EXPOSURE_REFERENCE = 2_000
      DECAY_ANCHOR = 50
      DECAY_RATE = 0.01

      attr_reader :value

      def self.default
        new(50)
      end

      def initialize(value)
        raise ArgumentError, '評判は数値でなければなりません' unless value.is_a?(Numeric)

        @value = value.clamp(MIN, MAX).to_f
        freeze
      end

      def after_day(experience:, exposure: 0, events: [])
        value = @value
        value += drift(experience, value, exposure)
        value += decay(value)
        value += events.sum(&:reputation_delta)
        self.class.new(value)
      end

      def score
        @value.round
      end

      def gain(amount)
        self.class.new(@value + amount)
      end

      def lose(amount)
        self.class.new(@value - amount)
      end

      def <=>(other)
        return nil unless other.is_a?(Reputation)

        @value <=> other.value
      end

      def to_s
        "#{score}/#{MAX}"
      end

      protected

      def components
        [@value]
      end

      private

      def drift(experience, value, exposure)
        gap = experience - value
        cap = gap.negative? ? DRIFT_CAP * DOWN_MULTIPLIER : DRIFT_CAP
        gap.clamp(-cap, cap) * exposure_factor(exposure)
      end

      def decay(value)
        return 0.0 unless value > DECAY_ANCHOR

        -DECAY_RATE * (value - DECAY_ANCHOR)
      end

      def exposure_factor(exposure)
        return 0.0 unless exposure.positive?

        [exposure.to_f / EXPOSURE_REFERENCE, 1.0].min
      end
    end
  end
end
