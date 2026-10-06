# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Animal < BaseObject
          field :id, ID, null: false
          field :name, String
          field :species, Species, null: false
          field :sex, String, null: false, method: :sex_label
          field :life_stage, String, null: false, method: :life_stage_label
          field :age_in_days, Integer, null: false
          field :alive, Boolean, null: false, method: :alive?
          field :cause_of_death, String, method: :cause_of_death_label
          field :health, Integer, null: false, method: :current_health
          field :max_health, Integer, null: false
          field :weak, Boolean, null: false, method: :weak?
          field :ailing, Boolean, null: false, method: :ailing?
          field :visible_condition, Integer, null: false
          field :blemishes, [Blemish], null: false
          field :stressors, [Stressor], null: false
          field :hunger, Integer, null: false, method: :hunger_level
          field :hungry, Boolean, null: false, method: :hungry?
          field :starving, Boolean, null: false, method: :starving?
          field :days_until_starving, Integer, null: false
          field :fed_today, Boolean, null: false, method: :fed_today?
          field :meals_today, [FoodCategory], null: false
          field :diet_categories, [FoodCategory], null: false, method: :acceptable_food_categories
          field :nutrition, Integer, null: false, method: :nutrition_level
          field :malnourished, Boolean, null: false, method: :malnourished?
          field :stress, Integer, null: false, method: :stress_level
          field :stressed, Boolean, null: false, method: :stressed?
          field :severely_stressed, Boolean, null: false, method: :severely_stressed?
          field :sick, Boolean, null: false, method: :sick?
          field :illness, String, method: :illness_name
          field :contagious, Boolean, null: false, method: :contagious?
          field :expecting, Boolean, null: false, method: :expecting?
          field :gestation_days, Integer
          field :gestation_period_days, Integer
          field :ready_to_deliver, Boolean, null: false, method: :ready_to_deliver?
          field :parents, [Animal], null: false
          field :enclosure, Enclosure
          field :prognosis, Prognosis
          field :companionship, Companionship
          field :thermal_suitability, ThermalSuitability

          def meals_today
            object.meals.categories
          end

          def blemishes
            {
              stressed: [object.stressed?, Domain::Animal::VISIBLE_STRESSED_PENALTY],
              sick: [object.sick?, Domain::Animal::VISIBLE_SICK_PENALTY],
              weak: [object.weak?, Domain::Animal::VISIBLE_WEAK_PENALTY]
            }.filter_map { |cause, (present, penalty)| { cause:, penalty: } if present }
          end

          def stressors
            occupancy = housed_occupancy or return []

            enclosure = occupancy.enclosure
            fellowship = companionship
            welfare = Domain::Welfare
            {
              filth: [enclosure.filthy?, welfare::FILTH],
              boredom: [enclosure.barren?, welfare::BOREDOM],
              crowding: [occupancy.overcrowded?, welfare::CROWDING],
              loneliness: [fellowship.lonely?, welfare::LONELINESS],
              maternal_separation: [fellowship.separated_dependent?, welfare::MATERNAL_SEPARATION],
              social_conflict: [fellowship.subordinate_male?, welfare::SOCIAL_CONFLICT],
              climate_discomfort: [!thermal_suitability.comfortable?, welfare::CLIMATE_DISCOMFORT],
              hunger: [object.hungry?, welfare::HUNGER],
              illness: [object.sick?, welfare::ILLNESS],
              malnutrition: [object.malnourished?, welfare::MALNUTRITION]
            }.filter_map { |cause, (present, amount)| { cause:, amount: } if present }
          end

          def parents
            object.parent_ids.filter_map { |id| container.animals.find(id) }
          end

          def enclosure
            container.housings.enclosure_of(object)
          end

          def prognosis
            occupancy = housed_occupancy or return

            Domain::Prognosis.new(
              animal: object, enclosure: occupancy.enclosure, occupancy:, season: container.zoo.load.season
            )
          end

          def companionship
            occupancy = housed_occupancy or return

            Domain::Companionship.new(enclosure: occupancy.enclosure, occupancy:, member: object)
          end

          def thermal_suitability
            occupancy = housed_occupancy or return

            Domain::ThermalSuitability.new(
              object, occupancy.enclosure.effective_temperature(container.zoo.load.season)
            )
          end

          private

          def housed_occupancy
            container.housings.all_occupancies.find { |occupancy| occupancy.include?(object) }
          end
        end
      end
    end
  end
end
