# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      RenameAnimalCommand = Data.define(:animal_id, :new_name, :animals, :unit_of_work) do
        def initialize(animal_id:, new_name:, animals: nil, unit_of_work: nil)
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?
          raise ArgumentError, 'new_name は必須です' if new_name.nil?

          super
        end

        def bind(animals:, unit_of_work:, **)
          with(animals:, unit_of_work:)
        end
      end
    end
  end
end
