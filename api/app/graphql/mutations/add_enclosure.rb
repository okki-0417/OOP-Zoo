# frozen_string_literal: true

module Mutations
  class AddEnclosure < BaseMutation
    type Types::Enclosure, null: false

    argument :name, String
    argument :celsius, Integer
    argument :capacity, Integer
    argument :climate_controlled, Boolean, required: false, default_value: false

    def resolve(**)
      perform(:add_enclosure, **)
    end
  end
end
