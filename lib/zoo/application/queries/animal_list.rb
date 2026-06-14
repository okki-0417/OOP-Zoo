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
              alive: animal.alive?
            )
          end
        end
      end
    end
  end
end
