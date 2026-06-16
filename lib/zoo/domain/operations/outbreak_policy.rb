# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      module OutbreakPolicy
        module_function

        CHANCE_PERCENT = 20

        def strike(animals, random)
          healthy = animals.select { |animal| animal.alive? && !animal.sick? }
          return nil if healthy.empty?
          return nil unless random.rand(100) < CHANCE_PERCENT

          healthy[random.rand(healthy.size)]
        end
      end
    end
  end
end
