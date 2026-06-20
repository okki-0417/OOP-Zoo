# frozen_string_literal: true

module Zoo
  module Domain
    class Contagion
      BASE_CHANCE = 50
      FILTH_BONUS = 30
      CROWDING_BONUS = 20

      def initialize(enclosure, random: nil)
        @enclosure = enclosure
        @random = random
      end

      def spread
        return [] if active_contagions.empty?

        @enclosure.occupants.each_with_object([]) do |animal, infected|
          next unless susceptible?(animal)

          illness = active_contagions.find { |ill| !animal.immune_to?(ill) }
          next unless illness
          next if @random && @random.rand(100) >= transmission_chance

          animal.fall_ill(illness)
          infected << animal
        end
      end

      def transmission_chance
        chance = BASE_CHANCE
        chance += FILTH_BONUS if @enclosure.filthy?
        chance += CROWDING_BONUS if @enclosure.overcrowded?
        [chance, 100].min
      end

      private

      def active_contagions
        @active_contagions ||= @enclosure.occupants
                                         .select { |a| a.alive? && a.sick? && a.illness_contagious? }
                                         .map(&:illness)
                                         .uniq
      end

      def susceptible?(animal)
        animal.alive? && !animal.sick?
      end
    end
  end
end
