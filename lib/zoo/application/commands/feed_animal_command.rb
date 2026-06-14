# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      FeedAnimalCommand = Data.define(:keeper_id, :animal_id, :food) do
        def initialize(keeper_id:, animal_id:, food:)
          raise ArgumentError, 'keeper_id は必須です' if keeper_id.nil?
          raise ArgumentError, 'animal_id は必須です' if animal_id.nil?
          raise ArgumentError, 'food は必須です' if food.nil?

          super
        end
      end
    end
  end
end
