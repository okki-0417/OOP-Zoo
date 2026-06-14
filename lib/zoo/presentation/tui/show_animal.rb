# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class ShowAnimal < Action
        def call
          animal_id = choose_animal or return @output.puts('個体がいません')

          @output.puts @view.animal_detail(@container.animal_detail.call(animal_id))
        end
      end
    end
  end
end
