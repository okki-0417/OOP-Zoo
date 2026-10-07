# frozen_string_literal: true

module Mutations
  class HireVeterinarian < BaseMutation
    type Types::Veterinarian, null: false

    argument :name, String

    def resolve(**)
      perform(:hire_veterinarian, **)
    end
  end
end
