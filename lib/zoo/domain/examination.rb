# frozen_string_literal: true

module Zoo
  module Domain
    class Examination
      def initialize(veterinarian:, animal:)
        @veterinarian = veterinarian
        @animal = animal
      end

      def diagnosis
        return :dead if @animal.dead?
        return :sick if @animal.sick?
        return :injured if @animal.weak?

        :healthy
      end

      def to_s
        "#{@veterinarian.name}が#{@animal.name}を診察"
      end
    end
  end
end
