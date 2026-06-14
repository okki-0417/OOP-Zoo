# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      ReleaseAnimalCommand = Data.define(:animal_id) do
        def initialize(animal_id:)
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?

          super(animal_id: animal_id)
        end
      end
    end
  end
end
