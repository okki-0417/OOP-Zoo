# frozen_string_literal: true

module Zoo
  module Domain
    class AnimalDay
      def initialize(animal:, enclosure:, occupancy:, season: Season.spring)
        @animal = animal
        @companionship = Companionship.new(enclosure: enclosure, occupancy: occupancy, member: animal)
        @welfare = Welfare.new(
          animal: animal, enclosure: enclosure, occupancy: occupancy,
          companionship: @companionship,
          thermal_suitability: ThermalSuitability.new(animal, enclosure.effective_temperature(season))
        )
      end

      def run
        return if @animal.dead?

        apply_welfare
        @animal.injure(@companionship.injury)
        @animal.grow_older(1) unless @animal.dead?
      end

      private

      def apply_welfare
        delta = @welfare.daily_stress
        delta.negative? ? @animal.relieve_stress(-delta) : @animal.add_stress(delta)
      end
    end
  end
end
