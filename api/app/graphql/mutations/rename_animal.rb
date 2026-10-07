# frozen_string_literal: true

module Mutations
  class RenameAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID
    argument :new_name, String

    def resolve(**)
      perform(:rename_animal, **)
    end
  end
end
