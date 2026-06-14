# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      ExamineAnimalCommand = Data.define(:veterinarian_id, :animal_id) do
        def initialize(veterinarian_id:, animal_id:)
          raise ArgumentError, 'veterinarian_id は必須です' if veterinarian_id.nil?
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?

          super(veterinarian_id: veterinarian_id, animal_id: animal_id)
        end
      end
    end
  end
end
