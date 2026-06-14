# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Feed < Command
        def run(args)
          keeper_id, animal_id, food_key = args
          raise ArgumentError, '使い方: feed KEEPER_ID ANIMAL_ID FOOD' if [keeper_id, animal_id, food_key].any?(&:nil?)

          food = Domain::Feeding::FoodCatalog.find(food_key) or raise ArgumentError, "未知の餌です: #{food_key}"
          command = Application::Commands::FeedAnimalCommand.new(keeper_id: keeper_id, animal_id: animal_id, food: food)
          animal = @container.feed_animal.call(command)
          @output.puts "給餌しました: #{animal.name}（空腹度 #{animal.hunger.level}）"
        end
      end
    end
  end
end
