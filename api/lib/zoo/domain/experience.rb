# frozen_string_literal: true

module Zoo
  module Domain
    class Experience
      FEE_PER_EXPECTATION = 500

      def initialize(on_exhibit:, fee:)
        @on_exhibit = on_exhibit
        @fee = fee
      end

      def score
        (ExhibitCondition.new(@on_exhibit).score - (@fee.yen / FEE_PER_EXPECTATION)).clamp(0, 100)
      end
    end
  end
end
