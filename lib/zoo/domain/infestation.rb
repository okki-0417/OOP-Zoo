# frozen_string_literal: true

module Zoo
  module Domain
    class Infestation
      def initialize(enclosure, occupancy)
        @enclosure = enclosure
        @occupancy = occupancy
      end

      def spread
        return [] unless @enclosure.filthy?

        @occupancy.each_with_object([]) do |animal, infected|
          next unless animal.susceptible?

          animal.fall_ill(IllnessCatalog.parasite)
          infected << animal
        end
      end
    end
  end
end
