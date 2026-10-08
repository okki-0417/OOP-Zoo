# frozen_string_literal: true

module Mutations
  class HireVeterinarian < BaseMutation
    type Types::Veterinarian, null: false

    argument :name, String

    def resolve(name:)
      Hiring.new(zoo: current_zoo, employee: Veterinarian.new(name:)).perform
    end
  end
end
