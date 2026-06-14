# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class HouseAnimal < Action
        def call
          animal_id = choose_animal or return @output.puts('個体がいません')
          enclosure_id = choose_enclosure or return @output.puts('エリアがありません')

          command = Application::Commands::HouseAnimalCommand.new(
            enclosure_id: enclosure_id, animal_id: animal_id
          )
          enclosure = @container.house_animal.call(command)
          @output.puts "収容しました: #{enclosure.name}（#{enclosure.population}頭）"
        end
      end
    end
  end
end
