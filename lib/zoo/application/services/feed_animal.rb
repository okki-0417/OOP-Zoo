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
            food = @command.foods.find(@command.food_code) or
              raise Errors::FoodNotFound, "未知の餌です: #{@command.food_code}"

            animal = @command.unit_of_work.run do
              keeper = @command.keepers.find(@command.keeper_id)
              raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

              animal = @command.animals.find(@command.animal_id)
              raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

              Domain::Feeding.new(keeper: keeper, animal: animal, foods: [food]).serve
              @command.animals.save(animal)
              @command.keepers.save(keeper)
              animal
            end
            { animal:, enclosure: @command.housings.enclosure_of(animal) }
          end
        end
      end
    end
  end
end
