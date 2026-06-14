# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class TransferAnimal < Action
        def call
          animal_id = choose_animal('移送する個体') or return @output.puts('個体がいません')
          enclosure_id = choose_enclosure('移送先エリア') or return @output.puts('エリアがありません')

          enclosure = @container.transfer_animal.call(
            Application::Commands::TransferAnimalCommand.new(animal_id: animal_id, enclosure_id: enclosure_id)
          )
          @output.puts "移送しました: #{enclosure.name}（#{enclosure.population}頭）"
        end
      end
    end
  end
end
