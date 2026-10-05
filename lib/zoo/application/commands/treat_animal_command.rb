# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      TreatAnimalCommand = Data.define(
        :veterinarian_id, :animal_id,
        :veterinarians, :animals, :unit_of_work
      ) do
        def initialize(veterinarian_id:, animal_id:, veterinarians: nil, animals: nil, unit_of_work: nil)
          raise ArgumentError, 'veterinarian_id は必須です' if veterinarian_id.nil?
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?

          super
        end

        def bind(veterinarians:, animals:, unit_of_work:, **)
          with(veterinarians:, animals:, unit_of_work:)
        end
      end
    end
  end
end
