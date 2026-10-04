# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      ReleaseAnimalCommand = Data.define(:animal_id, :animals, :housings, :unit_of_work) do
        def initialize(animal_id:, animals: nil, housings: nil, unit_of_work: nil)
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?

          super
        end

        def bind(animals:, housings:, unit_of_work:, **)
          with(animals:, housings:, unit_of_work:)
        end
      end
    end
  end
end
