# frozen_string_literal: true

module Zoo
  module Domain
    module Medical
      module Contagion
        module_function

        BASE_CHANCE = 50
        FILTH_BONUS = 30
        CROWDING_BONUS = 20

        def spread(enclosure, random: nil)
          illnesses = active_contagions(enclosure)
          return [] if illnesses.empty?

          chance = transmission_chance(enclosure)
          enclosure.occupants.each_with_object([]) do |animal, infected|
            next unless susceptible?(animal)

            illness = illnesses.find { |ill| !animal.immune_to?(ill) }
            next unless illness
            next if random && random.rand(100) >= chance

            animal.fall_ill(illness)
            infected << animal
          end
        end

        def transmission_chance(enclosure)
          chance = BASE_CHANCE
          chance += FILTH_BONUS if enclosure.filthy?
          chance += CROWDING_BONUS if Husbandry::Stocking.overcrowded?(enclosure)
          [chance, 100].min
        end

        def active_contagions(enclosure)
          enclosure.occupants
                   .select { |a| a.alive? && a.sick? && a.illness.contagious? }
                   .map(&:illness)
                   .uniq
        end

        def susceptible?(animal)
          animal.alive? && !animal.sick?
        end
      end
    end
  end
end
