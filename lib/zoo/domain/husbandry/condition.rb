# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      module Condition
        module_function

        NEUTRAL = 50
        STRESSED_PENALTY = 40
        SICK_PENALTY = 40
        WEAK_PENALTY = 20

        def score(animals)
          living = animals.select(&:alive?)
          return NEUTRAL if living.empty?

          living.sum { |animal| individual_score(animal) } / living.size
        end

        def individual_score(animal)
          score = 100
          score -= STRESSED_PENALTY if animal.stressed?
          score -= SICK_PENALTY if animal.sick?
          score -= WEAK_PENALTY if animal.health.weak?
          [score, 0].max
        end
      end
    end
  end
end
