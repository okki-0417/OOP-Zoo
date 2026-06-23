# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class AnimalList
        def initialize(animals:)
          @animals = animals
        end

        def call
          @animals.all.map do |animal|
            ReadModels::AnimalSummary.new(
              id: animal.id.to_s,
              name: animal.name,
              species: animal.species_name,
              alive: animal.alive?,
              health: animal.current_health,
              max_health: animal.max_health,
              ailing: animal.alive? && (animal.sick? || animal.starving? || animal.weak?)
            )
          end
        end
      end
    end
  end
end
