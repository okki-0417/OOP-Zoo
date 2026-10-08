# frozen_string_literal: true

module Mutations
  class FeedAnimal < BaseMutation
    type Types::Animal, null: false

    argument :animal_id, ID
    argument :keeper_id, ID
    argument :food_code, String

    def resolve(animal_id:, keeper_id:, food_code:)
      Feeding.new(
        keeper: current_zoo.keepers.find(keeper_id), animal: current_zoo.animals.find(animal_id), foods: [FoodCatalog.find!(food_code)]
      ).serve
    end
  end
end
