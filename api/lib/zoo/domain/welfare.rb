# frozen_string_literal: true

module Zoo
  module Domain
    class Welfare
      FILTH = 15
      BOREDOM = 10
      CROWDING = 12
      LONELINESS = 12
      MATERNAL_SEPARATION = 14
      SOCIAL_CONFLICT = 12
      CLIMATE_DISCOMFORT = 10
      HUNGER = 10
      ILLNESS = 12
      MALNUTRITION = 12
      RECOVERY = 15

      def initialize(animal:, enclosure:, occupancy:, companionship:, thermal_suitability:)
        @animal = animal
        @enclosure = enclosure
        @occupancy = occupancy
        @companionship = companionship
        @thermal_suitability = thermal_suitability
      end

      def daily_stress
        total = 0
        total += FILTH               if @enclosure.filthy?
        total += BOREDOM             if @enclosure.barren?
        total += CROWDING            if @occupancy.overcrowded?
        total += LONELINESS          if @companionship.lonely?
        total += MATERNAL_SEPARATION if @companionship.separated_dependent?
        total += SOCIAL_CONFLICT     if @companionship.subordinate_male?
        total += CLIMATE_DISCOMFORT  unless @thermal_suitability.comfortable?
        total += HUNGER              if @animal.hungry?
        total += ILLNESS             if @animal.sick?
        total += MALNUTRITION        if @animal.malnourished?
        total.positive? ? total : -RECOVERY
      end
    end
  end
end
