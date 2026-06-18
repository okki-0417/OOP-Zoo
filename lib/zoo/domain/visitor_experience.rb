# frozen_string_literal: true

module Zoo
  module Domain
    module VisitorExperience
      module_function

      FEE_PER_EXPECTATION = 500

      def score(condition:, fee:)
        (condition - expectation_penalty(fee)).clamp(0, 100)
      end

      def expectation_penalty(fee)
        fee.yen / FEE_PER_EXPECTATION
      end
    end
  end
end
