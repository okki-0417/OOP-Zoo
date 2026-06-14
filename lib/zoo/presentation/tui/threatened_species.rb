# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class ThreatenedSpecies < Action
        def call
          @output.puts @view.threatened_table(@container.threatened_species.call)
        end
      end
    end
  end
end
