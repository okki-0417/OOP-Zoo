# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      module Aggression
        module_function

        BASE_INJURY = 5
        CROWDING_AGGRAVATION = 5
        NO_REFUGE_AGGRAVATION = 5

        def injury_for(animal, enclosure)
          return 0 unless SocialStructure.subordinate_male?(animal, enclosure)

          injury = BASE_INJURY
          injury += CROWDING_AGGRAVATION if Stocking.overcrowded?(enclosure)
          injury += NO_REFUGE_AGGRAVATION if enclosure.barren?
          injury
        end
      end
    end
  end
end
