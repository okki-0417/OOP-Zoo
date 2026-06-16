# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      module Metabolism
        module_function

        REFERENCE_KG = 190.0

        BASE_HUNGER_PER_DAY = 10
        HUNGER_MIN = 1
        HUNGER_MAX = 30

        FOOD_COST_REFERENCE_KG = 100.0

        FOOD_COST_BASE_YEN = 450
        FOOD_COST_MIN_YEN = 100
        PREDATORY_DIET_FACTOR = 3.5

        SATIETY_FACTOR_RANGE = (0.3..3.0)

        def daily_hunger(species)
          factor = (REFERENCE_KG / species.adult_weight.kilograms)**0.25
          (BASE_HUNGER_PER_DAY * factor).round.clamp(HUNGER_MIN, HUNGER_MAX)
        end

        def satiety(species, food)
          factor = ((REFERENCE_KG / species.adult_weight.kilograms)**0.25).clamp(SATIETY_FACTOR_RANGE.begin,
                                                                                 SATIETY_FACTOR_RANGE.end)
          [(food.satiety * factor).round, 1].max
        end

        def daily_food_cost(species)
          mass_factor = (species.adult_weight.kilograms / FOOD_COST_REFERENCE_KG)**0.75
          diet_factor = species.predatory? ? PREDATORY_DIET_FACTOR : 1.0
          yen = (FOOD_COST_BASE_YEN * mass_factor * diet_factor).round
          Shared::Money.yen([yen, FOOD_COST_MIN_YEN].max)
        end
      end
    end
  end
end
