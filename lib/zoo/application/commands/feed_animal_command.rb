# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      FeedAnimalCommand = Data.define(
        :keeper_id, :animal_id, :food_code,
        :keepers, :animals, :housings, :foods, :unit_of_work
      ) do
        def initialize(keeper_id:, animal_id:, food_code:, keepers: nil, animals: nil, housings: nil, foods: nil,
                       unit_of_work: nil)
          raise ArgumentError, 'keeper_id は必須です' if keeper_id.nil?
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?
          raise ArgumentError, 'food_code は必須です' if food_code.nil?

          super
        end

        def bind(keepers:, animals:, housings:, foods:, unit_of_work:, **)
          with(keepers:, animals:, housings:, foods:, unit_of_work:)
        end
      end
    end
  end
end
