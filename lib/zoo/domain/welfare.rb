# frozen_string_literal: true

module Zoo
  module Domain
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

      def daily_stress(animal, enclosure, occupants, season: Season.spring)
        total = stressor_total(animal, enclosure, occupants, season)
        total.positive? ? total : -RECOVERY
      end

      def separated_dependent?(animal, occupants)
        return false if animal.weaned? || animal.parent_ids.empty?

        parent_present = occupants.any? do |other|
          other.alive? && animal.parent_ids.include?(other.id)
        end
        !parent_present
      end

      def lonely?(animal, occupants)
        return false unless animal.species.group_living?

        companions = occupants.count do |other|
          other.alive? && other.species == animal.species
        end
        companions <= 1
      end

      def stressor_total(animal, enclosure, occupants, season)
        total = 0
        total += FILTH if enclosure.filthy?
        total += LONELINESS if lonely?(animal, occupants)
        total += SOCIAL_CONFLICT if SocialConflict.new(enclosure, occupants, animal).subordinate_male?
        total += CROWDING if Occupancy.new(enclosure, occupants).overcrowded?
        total += CLIMATE_DISCOMFORT unless animal.species.comfortable?(enclosure.effective_temperature(season))
        total += HUNGER if animal.hungry?
        total += ILLNESS if animal.sick?
        total += MALNUTRITION if animal.malnourished?
        total += BOREDOM if enclosure.barren?
        total += MATERNAL_SEPARATION if separated_dependent?(animal, occupants)
        total
      end
    end
  end
end
