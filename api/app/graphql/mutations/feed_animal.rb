# frozen_string_literal: true

module Mutations
  class FeedAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID
    argument :keeper_id, ID
    argument :food_code, String

    def resolve(**)
      perform(:feed_animal, **)
    end
  end
end
