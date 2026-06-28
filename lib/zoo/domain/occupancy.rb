# frozen_string_literal: true

module Zoo
  module Domain
    class Occupancy
      include Enumerable

      attr_reader :enclosure

      def initialize(housings:, enclosure: nil)
        if housings.empty?
          raise ArgumentError, 'enclosure: required when no housings are given' unless enclosure

          @enclosure = enclosure
        else
          enclosures = housings.map(&:enclosure).uniq
          raise ArgumentError, '全 housing が同一エンクロージャに属する必要があります' if enclosures.size != 1

          @enclosure = enclosures.first
        end
        @occupants = housings.map(&:animal)
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
