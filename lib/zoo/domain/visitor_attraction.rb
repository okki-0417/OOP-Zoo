# frozen_string_literal: true

module Zoo
  module Domain
    class VisitorAttraction
      WILLINGNESS_BASE_YEN = 3_000
      WILLINGNESS_PER_SPECTACLE_YEN = 15

      def initialize(on_exhibit:, reputation_factor:, admission_fee:, buzz: 0)
        @on_exhibit = on_exhibit
        @spectacle = Spectacle.new(on_exhibit: on_exhibit, buzz: buzz)
        @reputation_factor = reputation_factor
        @admission_fee = admission_fee
      end

      def expected_visitors
        return 0 if @on_exhibit.empty?

        spectacle = @spectacle.value
        q_max = spectacle * @reputation_factor
        p_max = WILLINGNESS_BASE_YEN + (spectacle * WILLINGNESS_PER_SPECTACLE_YEN * @reputation_factor)
        price = @admission_fee.yen
        return 0 if price >= p_max

        (q_max * (1.0 - (price.to_f / p_max))).to_i
      end
    end
  end
end
