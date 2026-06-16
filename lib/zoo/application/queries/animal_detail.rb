# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class AnimalDetail
        def initialize(animals:, enclosures:)
          @animals = animals
          @enclosures = enclosures
        end

        def call(animal_id)
          animal = @animals.find(animal_id)
          return nil if animal.nil?

          species = animal.species
          status = species.conservation_status
          enclosure = @enclosures.all.find { |e| e.houses?(animal) }
          ReadModels::AnimalProfile.new(
            id: animal.id.to_s,
            name: animal.name.to_s,
            species: species.name_ja,
            taxon_class: species.taxon_class.label,
            diet: species.diet_type.label,
            conservation_code: status.code,
            conservation_label: status.label,
            sex: animal.sex.label,
            life_stage: animal.life_stage.label,
            age_in_days: animal.age_in_days.value,
            health: animal.health.current,
            max_health: animal.health.max,
            weak: animal.health.weak?,
            hunger: animal.hunger.level,
            starving: animal.hunger.starving?,
            illness: animal.illness&.name_ja,
            alive: animal.alive?,
            cause: animal.death&.cause,
            parents: animal.parent_ids.size,
            enclosure_id: enclosure&.id&.to_s,
            enclosure_name: enclosure&.name
          )
        end
      end
    end
  end
end
