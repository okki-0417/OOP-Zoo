# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      module SocialStructure
        module_function

        def subordinate_male?(animal, enclosure)
          return false unless contender?(animal)

          rivals = enclosure.occupants.select { |other| contender?(other) && same_group?(other, animal) }
          return false if rivals.size < 2

          dominant = rivals.max_by { |male| male.age_in_days.value }
          animal.id != dominant.id
        end

        def contender?(animal)
          animal.alive? && animal.sex.male? && animal.mature? && animal.species.group_living?
        end

        def same_group?(other, animal)
          other.species.same_species?(animal.species)
        end
      end
    end
  end
end
