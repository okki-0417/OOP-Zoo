# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      FeedAnimalCommand = Data.define(:keeper_id, :animal_id, :food_code) do
        def initialize(keeper_id:, animal_id:, food_code:)
          raise ArgumentError, 'keeper_id は必須です' if keeper_id.nil?
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?
          raise ArgumentError, 'food_code は必須です' if food_code.nil?

          super
        end
      end
    end
  end
end
