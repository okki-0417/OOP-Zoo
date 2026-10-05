# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      AnimalSummary = Data.define(:id, :name, :species, :alive, :health, :max_health, :ailing, :hungry, :fed_today) do
        def self.of(animal)
          new(
            id: animal.id.to_s,
            name: animal.name,
            species: animal.species_name,
            alive: animal.alive?,
            health: animal.current_health,
            max_health: animal.max_health,
            ailing: animal.alive? && (animal.sick? || animal.starving? || animal.weak?),
            hungry: animal.alive? && animal.hungry?,
            fed_today: animal.meals.variety.positive?
          )
        end
      end
    end
  end
end
