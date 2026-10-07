# frozen_string_literal: true

module Mutations
  class ReleaseAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID

    def resolve(animal_id:)
      Animal.find(animal_id).move_out.tap(&:save!)
    end
  end
end
