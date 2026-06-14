# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class ListEnclosures < Action
        def call
          @output.puts @view.enclosure_table(@container.enclosure_list.call)
        end
      end
    end
  end
end
