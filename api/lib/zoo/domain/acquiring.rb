# frozen_string_literal: true

module Zoo
  module Domain
    class Acquiring
      CONSERVATION_REPUTATION_GAIN = 5

      def initialize(zoo:, animal:)
        @zoo = zoo
        @animal = animal
      end

      def settle
        if @animal.tradeable?
          @zoo.purchase(@animal.acquisition_price)
        else
          @zoo.gain_reputation(CONSERVATION_REPUTATION_GAIN)
        end
      end
    end
  end
end
