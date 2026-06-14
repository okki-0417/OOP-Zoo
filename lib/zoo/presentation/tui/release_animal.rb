# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class ReleaseAnimal < Action
        def call
          animal_id = choose_animal('展示から外す個体') or return @output.puts('個体がいません')

          animal = @container.release_animal.call(
            Application::Commands::ReleaseAnimalCommand.new(animal_id: animal_id)
          )
          @output.puts "展示から外しました: #{animal.name}"
        end
      end
    end
  end
end
