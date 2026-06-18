# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class FeedAnimal < Action
        def call(params)
          food = Domain::FoodCatalog.find(params['food']) or
            raise ArgumentError, "未知の餌です: #{params['food']}"

          command = Application::Commands::FeedAnimalCommand.new(
            keeper_id: params['keeper_id'], animal_id: params['id'], food: food
          )
          animal = @container.feed_animal.call(command)
          [200, Serializer.animal(@container.animal_detail.call(animal.id))]
        end
      end
    end
  end
end
