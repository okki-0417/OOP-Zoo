# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AnimalDetailCommand = Data.define(:animal_id, :animals, :housings) do
        def initialize(animal_id:, animals: nil, housings: nil)
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?

          super
        end

        def bind(animals:, housings:, **)
          with(animals:, housings:)
        end
      end
    end
  end
end
