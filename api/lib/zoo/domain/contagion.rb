# frozen_string_literal: true

module Zoo
  module Domain
    class Contagion
      BASE_CHANCE = 50
      FILTH_BONUS = 30
      CROWDING_BONUS = 20

      def initialize(enclosure, occupancy, random: nil)
        @enclosure = enclosure
        @occupancy = occupancy
        @random = random
      end

      def spread
        contagious = @occupancy.contagious_illnesses
        return [] if contagious.empty?

        @occupancy.each_with_object([]) do |animal, infected|
          next unless animal.susceptible?

          illness = animal.contractible_illness(contagious)
          next unless illness
          next if transmission_blocked?

          animal.fall_ill(illness)
          infected << animal
        end
      end

      private

      def transmission_blocked?
        @random && @random.rand(100) >= transmission_chance
      end

      def transmission_chance
        chance = BASE_CHANCE
        chance += FILTH_BONUS if @enclosure.filthy?
        chance += CROWDING_BONUS if @occupancy.overcrowded?
        [chance, 100].min
      end
    end
  end
end
