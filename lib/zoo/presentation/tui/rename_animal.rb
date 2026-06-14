# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class RenameAnimal < Action
        def call
          animal_id = choose_animal('改名する個体') or return @output.puts('個体がいません')
          new_name = @prompt.ask('新しい名前:')

          animal = @container.rename_animal.call(
            Application::Commands::RenameAnimalCommand.new(animal_id: animal_id, new_name: new_name)
          )
          @output.puts "改名しました: #{animal.name}"
        end
      end
    end
  end
end
