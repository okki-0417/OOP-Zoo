# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      module Welfare
        module_function

        FILTH = 15
        LONELINESS = 12
        SOCIAL_CONFLICT = 12
        CROWDING = 12
        CLIMATE_DISCOMFORT = 10
        HUNGER = 10
        ILLNESS = 12
        MALNUTRITION = 12
        BOREDOM = 10
        MATERNAL_SEPARATION = 14
        RECOVERY = 15

        def daily_stress(animal, enclosure, season: Operations::Season.spring)
          total = stressor_total(animal, enclosure, season)
          total.positive? ? total : -RECOVERY
        end

        def separated_dependent?(animal, enclosure)
          return false if animal.weaned? || animal.parent_ids.empty?

          parent_present = enclosure.occupants.any? do |other|
            other.alive? && animal.parent_ids.include?(other.id)
          end
          !parent_present
        end

        def lonely?(animal, enclosure)
          return false unless animal.species.group_living?

          companions = enclosure.occupants.count do |other|
            other.alive? && other.species.same_species?(animal.species)
          end
          companions <= 1
        end

        def stressor_total(animal, enclosure, season)
          total = 0
          total += FILTH if enclosure.filthy?
          total += LONELINESS if lonely?(animal, enclosure)
          total += SOCIAL_CONFLICT if enclosure.subordinate_male?(animal)
          total += CROWDING if enclosure.overcrowded?
          total += CLIMATE_DISCOMFORT unless animal.species.comfortable?(enclosure.effective_temperature(season))
          total += HUNGER if animal.hungry?
          total += ILLNESS if animal.sick?
          total += MALNUTRITION if animal.malnourished?
          total += BOREDOM if enclosure.barren?
          total += MATERNAL_SEPARATION if separated_dependent?(animal, enclosure)
          total
        end
      end
    end
  end
end
