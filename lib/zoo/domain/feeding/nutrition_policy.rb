# frozen_string_literal: true

module Zoo
  module Domain
    module Feeding
      module NutritionPolicy
        module_function

        REQUIRED_VARIETY_CAP = 2

        def balanced?(species, foods)
          offered_categories(species, foods).size >= required_variety(species)
        end

        def required_variety(species)
          [species.diet_type.acceptable_categories.size, REQUIRED_VARIETY_CAP].min
        end

        def offered_categories(species, foods)
          diet = species.diet_type
          foods.select { |food| diet.accepts?(food.category) }
               .map(&:category)
               .uniq
        end
      end
    end
  end
end
