# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class FeedAnimal
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:feed_animal) do
            food = Domain::FoodCatalog.find(@command.food_code) or
              raise Errors::FoodNotFound, "未知の餌です: #{@command.food_code}"

            ApplicationRecord.transaction do
              keeper = Domain::Keeper.find_by(id: @command.keeper_id)
              raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

              animal = Domain::Animal.find_by(id: @command.animal_id)
              raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

              Domain::Feeding.new(keeper: keeper, animal: animal, foods: [food]).serve
              animal.save!
              keeper.save!
              animal
            end
          end
        end
      end
    end
  end
end
