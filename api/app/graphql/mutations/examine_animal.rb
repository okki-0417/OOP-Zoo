# frozen_string_literal: true

module Mutations
  class ExamineAnimal < BaseMutation
    type Types::Examination, null: false

    argument :animal_id, ID
    argument :veterinarian_id, ID

    def resolve(animal_id:, veterinarian_id:)
      animal = Animal.find(animal_id)
      { animal:, diagnosis: Examining.new(veterinarian: Veterinarian.find(veterinarian_id), animal:).diagnosis }
    end
  end
end
