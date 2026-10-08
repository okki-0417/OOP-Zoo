# frozen_string_literal: true

module Mutations
  class TreatAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID
    argument :veterinarian_id, ID

    def resolve(animal_id:, veterinarian_id:)
      Treating.new(veterinarian: Veterinarian.find(veterinarian_id), animal: Animal.find(animal_id)).perform
    end
  end
end
