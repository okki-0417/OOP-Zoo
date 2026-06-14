# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class TreatAnimal < Action
        def call
          veterinarian_id = choose_veterinarian or return @output.puts('獣医がいません')
          animal_id = choose_animal or return @output.puts('個体がいません')

          animal = @container.treat_animal.call(
            Application::Commands::TreatAnimalCommand.new(veterinarian_id: veterinarian_id, animal_id: animal_id)
          )
          @output.puts "治療しました: #{animal.name}"
        end
      end
    end
  end
end
