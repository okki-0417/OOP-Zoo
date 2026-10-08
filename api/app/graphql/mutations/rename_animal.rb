# frozen_string_literal: true

module Mutations
  class RenameAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID
    argument :new_name, String

    def resolve(animal_id:, new_name:)
      Animal.find(animal_id).change_name(new_name).tap(&:save!)
    end
  end
end
