# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class House < Command
        def run(args)
          enclosure_id, animal_id = args
          raise ArgumentError, '使い方: house ENCLOSURE_ID ANIMAL_ID' if [enclosure_id, animal_id].any?(&:nil?)

          command = Application::Commands::HouseAnimalCommand.new(enclosure_id: enclosure_id, animal_id: animal_id)
          enclosure = @container.house_animal.call(command)
          @output.puts "収容しました: #{enclosure.name}（在園 #{enclosure.population}頭）"
        end
      end
    end
  end
end
