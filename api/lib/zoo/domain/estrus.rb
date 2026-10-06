# frozen_string_literal: true

module Zoo
  module Domain
    class Estrus
      def initialize(animal, season)
        raise ArgumentError, '発情はメスにのみ起こります' unless animal.female?

        @animal = animal
        @season = season
      end

      def active?
        @animal.breeds_year_round? || @animal.breeding_season == @season.value
      end
    end
  end
end
