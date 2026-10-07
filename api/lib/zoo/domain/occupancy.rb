# frozen_string_literal: true

module Zoo
  module Domain
    class Occupancy
      include Enumerable

      attr_reader :enclosure

      def self.of(enclosure)
        new(enclosure:, occupants: enclosure.animals.select(&:alive?))
      end

      def self.all
        Enclosure.includes(animals: %i[sire dam]).order(:id).map { |enclosure| of(enclosure) }.select(&:any?)
      end

      def initialize(enclosure:, occupants: [])
        @enclosure = enclosure
        @occupants = occupants
      end

      def each(&)
        @occupants.each(&)
      end

      def full?
        @occupants.size >= @enclosure.capacity
      end

      def species_present_in
        @occupants.map(&:species).uniq
      end

      def required_area
        @occupants.sum(&:space_requirement_sqm)
      end

      def overcrowded?
        required_area > @enclosure.area_sqm
      end

      def contagious_illnesses
        @occupants.select(&:contagious?).map(&:illness).uniq
      end
    end
  end
end
