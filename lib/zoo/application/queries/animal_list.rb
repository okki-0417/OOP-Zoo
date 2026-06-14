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
              name: animal.name.to_s,
              species: animal.species.name_ja,
              alive: animal.alive?,
              health: animal.health.current,
              max_health: animal.health.max,
              ailing: animal.alive? && (animal.sick? || animal.starving? || animal.health.weak?)
            )
          end
        end
      end
    end
  end
end
