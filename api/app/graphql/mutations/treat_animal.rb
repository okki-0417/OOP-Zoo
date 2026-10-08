# frozen_string_literal: true

module Mutations
  class TreatAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID
    argument :veterinarian_id, ID

    def resolve(animal_id:, veterinarian_id:)
      Treating.new(veterinarian: current_zoo.veterinarians.find(veterinarian_id), animal: current_zoo.animals.find(animal_id)).perform
    end
  end
end
