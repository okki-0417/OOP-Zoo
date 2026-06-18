# frozen_string_literal: true

module Zoo
  module Domain
    module Condition
      module_function

      NEUTRAL = 50

      def score(animals)
        living = animals.select(&:alive?)
        return NEUTRAL if living.empty?

        living.sum(&:visible_condition) / living.size
      end
    end
  end
end
