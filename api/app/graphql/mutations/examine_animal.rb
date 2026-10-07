# frozen_string_literal: true

module Mutations
  class ExamineAnimal < BaseMutation
    type Types::Examination, null: false

    argument :animal_id, ID
    argument :veterinarian_id, ID

    def resolve(**)
      perform(:examine_animal, **)
    end
  end
end
