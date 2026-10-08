# frozen_string_literal: true

module Mutations
  class ExamineAnimal < BaseMutation
    type Types::Examination, null: false

    argument :animal_id, ID
    argument :veterinarian_id, ID

    def resolve(animal_id:, veterinarian_id:)
      animal = current_zoo.animals.find(animal_id)
      { animal:, diagnosis: Examining.new(veterinarian: current_zoo.veterinarians.find(veterinarian_id), animal:).diagnosis }
    end
  end
end
