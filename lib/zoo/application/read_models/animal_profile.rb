# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      AnimalProfile = Data.define(
        :id, :name, :species, :taxon_class, :diet, :conservation_code, :conservation_label,
        :sex, :life_stage, :age_in_days, :diet_categories, :health, :max_health, :weak,
        :hunger, :hungry, :starving, :days_until_starving, :meals_today,
        :nutrition, :malnourished, :stress, :stressed, :severely_stressed,
        :illness, :contagious, :expecting, :gestation_days, :gestation_period_days, :ready_to_deliver,
        :alive, :cause, :parents,
        :enclosure_id, :enclosure_name
      ) do
        def self.of(animal, enclosure:)
          new(
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
            diet_categories: animal.acceptable_food_categories.map(&:to_s),
            health: animal.current_health,
            max_health: animal.max_health,
            weak: animal.weak?,
            hunger: animal.hunger_level,
            hungry: animal.hungry?,
            starving: animal.starving?,
            days_until_starving: animal.days_until_starving,
            meals_today: animal.meals.categories.map(&:to_s),
            nutrition: animal.nutrition_level,
            malnourished: animal.malnourished?,
            stress: animal.stress_level,
            stressed: animal.stressed?,
            severely_stressed: animal.severely_stressed?,
            illness: animal.illness_name,
            contagious: animal.contagious?,
            expecting: animal.expecting?,
            gestation_days: animal.gestation_days,
            gestation_period_days: animal.gestation_period_days,
            ready_to_deliver: animal.ready_to_deliver?,
            alive: animal.alive?,
            cause: animal.cause_of_death_label,
            parents: animal.parent_ids.size,
            enclosure_id: enclosure&.id&.to_s,
            enclosure_name: enclosure&.name
          )
        end

        def self.housed(animal, housings:)
          enclosure = animal.alive? ? housings.current_housing_of(animal)&.enclosure : nil
          of(animal, enclosure: enclosure)
        end
      end
    end
  end
end
