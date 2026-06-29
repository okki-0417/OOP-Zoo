# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class DeceasedList
        def initialize(animals:)
          @animals = animals
        end

        def call
          @animals.all_deceased
                  .map { |animal| ReadModels::DeceasedRecord.new(name: animal.name, species: animal.species_name, cause: animal.cause_of_death) }
        end
      end
    end
  end
end
