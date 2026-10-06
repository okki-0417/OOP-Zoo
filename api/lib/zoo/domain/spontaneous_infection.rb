# frozen_string_literal: true

module Zoo
  module Domain
    class SpontaneousInfection
      CHANCE_PERCENT = 20

      def initialize(animals, random)
        @animals = animals
        @random = random
      end

      def strike
        target = pick
        return nil unless target

        target.fall_ill(IllnessCatalog.parasite)
        target
      end

      private

      def pick
        healthy = @animals.select(&:susceptible?)
        return nil if healthy.empty?
        return nil unless @random.rand(100) < CHANCE_PERCENT

        healthy[@random.rand(healthy.size)]
      end
    end
  end
end
