# frozen_string_literal: true

module Mutations
  class TreatAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID
    argument :veterinarian_id, ID

    def resolve(**)
      perform(:treat_animal, **)
    end
  end
end
