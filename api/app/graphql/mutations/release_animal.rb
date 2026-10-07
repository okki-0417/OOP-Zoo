# frozen_string_literal: true

module Mutations
  class ReleaseAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID

    def resolve(**)
      perform(:release_animal, **)
    end
  end
end
