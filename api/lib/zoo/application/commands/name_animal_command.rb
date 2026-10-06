# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      NameAnimalCommand = Data.define(:animal_id, :name, :animals, :unit_of_work) do
        def initialize(animal_id:, name:, animals: nil, unit_of_work: nil)
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?
          raise ArgumentError, 'name は必須です' if name.nil?

          super
        end

        def bind(animals:, unit_of_work:, **)
          with(animals:, unit_of_work:)
        end
      end
    end
  end
end
