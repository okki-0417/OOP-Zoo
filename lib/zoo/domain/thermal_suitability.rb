# frozen_string_literal: true

module Zoo
  module Domain
    class ThermalSuitability
      COMFORT_MARGIN = 0.15

      def initialize(animal, temperature)
        @animal = animal
        @temperature = temperature
      end

      def habitable?
        @animal.habitable_temperature_range.cover?(@temperature)
      end

      def comfortable?
        range = @animal.habitable_temperature_range
        low = range.begin.celsius
        high = range.end.celsius
        margin = (high - low) * COMFORT_MARGIN
        @temperature.celsius.between?(low + margin, high - margin)
      end
    end
  end
end
