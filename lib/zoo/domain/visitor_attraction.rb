# frozen_string_literal: true

module Zoo
  module Domain
    module VisitorAttraction
      module_function

      WILLINGNESS_BASE_YEN = 3_000
      WILLINGNESS_PER_SPECTACLE_YEN = 15
      SPECTACLE_SATURATION = 3_000

      def receive(zoo:, on_exhibit:)
        visitors = expected_visitors(on_exhibit, zoo.reputation_factor, zoo.admission_fee, buzz: zoo.buzz)
        income   = zoo.admit_visitors(visitors)
        [visitors, income]
      end

      def expected_visitors(animals, reputation_factor, admission_fee, buzz: 0)
        return 0 if animals.empty?

        spectacle = spectacle_of(animals, buzz)
        q_max = max_demand(spectacle, reputation_factor)
        p_max = willingness_to_pay(spectacle, reputation_factor)
        price = admission_fee.yen
        return 0 if price >= p_max

        (q_max * (1.0 - (price.to_f / p_max))).to_i
      end

      def spectacle_of(animals, buzz = 0)
        species = animals.map(&:species).uniq
        saturate(species.sum(&:charisma)) + buzz
      end

      def saturate(standing)
        SPECTACLE_SATURATION * standing / (standing + SPECTACLE_SATURATION).to_f
      end

      def max_demand(spectacle, reputation_factor)
        spectacle * reputation_factor
      end

      def willingness_to_pay(spectacle, reputation_factor)
        WILLINGNESS_BASE_YEN + (spectacle * WILLINGNESS_PER_SPECTACLE_YEN * reputation_factor)
      end
    end
  end
end
