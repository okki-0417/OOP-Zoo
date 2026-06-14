# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class FeedAnimal < Action
        def call
          keeper_id = choose_keeper or return @output.puts('飼育員がいません')
          animal_id = choose_animal or return @output.puts('個体がいません')
          food_key = @prompt.select('餌を選択', Domain::Feeding::FoodCatalog.keys, filter: true)

          command = Application::Commands::FeedAnimalCommand.new(
            keeper_id: keeper_id, animal_id: animal_id,
            food: Domain::Feeding::FoodCatalog.find(food_key)
          )
          animal = @container.feed_animal.call(command)
          @output.puts "給餌しました: #{animal.name}（空腹度 #{animal.hunger.level}）"
        end
      end
    end
  end
end
