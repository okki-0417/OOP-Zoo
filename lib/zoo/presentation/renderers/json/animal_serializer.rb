# frozen_string_literal: true

module Zoo
  module Presentation
    module Renderers
      module Json
        module AnimalSerializer
          module_function

          def animal_summary(summary)
            {
              id: summary.id, name: summary.name, species: summary.species, alive: summary.alive,
              health: summary.health, max_health: summary.max_health, ailing: summary.ailing,
              hungry: summary.hungry, fed_today: summary.fed_today
            }
          end

          def animal(profile)
            {
              id: profile.id, name: profile.name, species: profile.species,
              taxon_class: profile.taxon_class, diet: profile.diet,
              conservation_code: profile.conservation_code, conservation_label: profile.conservation_label,
              sex: profile.sex, life_stage: profile.life_stage, age_in_days: profile.age_in_days,
              health: profile.health, max_health: profile.max_health, weak: profile.weak,
              hunger: profile.hunger, hungry: profile.hungry, starving: profile.starving,
              days_until_starving: profile.days_until_starving, meals_today: profile.meals_today,
              nutrition: profile.nutrition, malnourished: profile.malnourished,
              stress: profile.stress, stressed: profile.stressed, severely_stressed: profile.severely_stressed,
              illness: profile.illness, contagious: profile.contagious,
              expecting: profile.expecting, gestation_days: profile.gestation_days,
              gestation_period_days: profile.gestation_period_days, ready_to_deliver: profile.ready_to_deliver,
              alive: profile.alive, cause: profile.cause, parents: profile.parents,
              enclosure_id: profile.enclosure_id, enclosure_name: profile.enclosure_name
            }
          end

          def animal_outlook(outlook)
            {
              animal_id: outlook.animal_id, housed: outlook.housed, outlook: outlook.outlook&.to_s,
              days_to_death: outlook.days_to_death, cause_of_death: outlook.cause_of_death
            }
          end
        end
      end
    end
  end
end
