# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class AnimalDetail
        def initialize(animals:, enclosures:, housings:)
          @animals = animals
          @enclosures = enclosures
          @housings = housings
        end

        def call(animal_id)
          animal = @animals.find(animal_id)
          return nil if animal.nil?

          enclosure_id = animal.alive? ? @housings.current_housing_of(animal)&.enclosure_id : nil
          enclosure = enclosure_id && @enclosures.find(enclosure_id)
          ReadModels::AnimalProfile.new(
            id: animal.id.to_s,
            name: animal.name,
            species: animal.species_name,
            taxon_class: animal.taxon_label,
            diet: animal.diet_label,
            conservation_code: animal.conservation_code,
            conservation_label: animal.conservation_label,
            sex: animal.sex_label,
            life_stage: animal.life_stage_label,
            age_in_days: animal.age_in_days,
            health: animal.current_health,
            max_health: animal.max_health,
            weak: animal.weak?,
            hunger: animal.hunger_level,
            starving: animal.starving?,
            illness: animal.illness_name,
            alive: animal.alive?,
            cause: animal.cause_of_death,
            parents: animal.parent_ids.size,
            enclosure_id: enclosure&.id&.to_s,
            enclosure_name: enclosure&.name
          )
        end
      end
    end
  end
end
