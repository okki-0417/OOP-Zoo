# frozen_string_literal: true

module Zoo
  module Domain
    module SpontaneousInfection
      module_function

      CHANCE_PERCENT = 20

      def apply(animals, random)
        target = strike(animals, random)
        return nil unless target

        target.fall_ill(IllnessCatalog.parasite)
        target
      end

      def strike(animals, random)
        healthy = animals.select(&:susceptible?)
        return nil if healthy.empty?
        return nil unless random.rand(100) < CHANCE_PERCENT

        healthy[random.rand(healthy.size)]
      end
    end
  end
end
