# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      RenameAnimalCommand = Data.define(:animal_id, :new_name) do
        def initialize(animal_id:, new_name:)
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?
          raise ArgumentError, 'new_name は必須です' if new_name.nil?

          super(animal_id: animal_id, new_name: new_name)
        end
      end
    end
  end
end
