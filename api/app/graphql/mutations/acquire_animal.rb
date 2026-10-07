# frozen_string_literal: true

module Mutations
  class AcquireAnimal < BaseMutation
    type Types::Animal, null: false

    argument :species_code, String
    argument :name, String
    argument :sex, Types::Sex

    def resolve(**)
      perform(:acquire_animal, **)
    end
  end
end
