# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class ListAnimals < Action
        def call
          @output.puts @view.animal_table(@container.animal_list.call)
        end
      end
    end
  end
end
