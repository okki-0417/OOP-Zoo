# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Rename < Command
        def run(args)
          animal_id, new_name = args
          raise ArgumentError, '使い方: rename ANIMAL_ID NEW_NAME' if [animal_id, new_name].any?(&:nil?)

          animal = @container.rename_animal.call(
            Application::Commands::RenameAnimalCommand.new(animal_id: animal_id, new_name: new_name)
          )
          @output.puts "改名しました: #{animal.name}"
        end
      end
    end
  end
end
