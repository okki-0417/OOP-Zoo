# frozen_string_literal: true

module Zoo
  module Domain
    module ReputationPolicy
      module_function

      DRIFT_CAP = 3
      DOWN_MULTIPLIER = 2

      EXPOSURE_REFERENCE = 2_000

      DECAY_ANCHOR = 50
      DECAY_RATE = 0.01

      def after_day(reputation, experience:, exposure: 0, events: [])
        value = reputation.value
        value += drift(experience, value, exposure)
        value += decay(value)
        value += events.sum(&:reputation_delta)
        Reputation.new(value)
      end

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
