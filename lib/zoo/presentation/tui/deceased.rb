# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class Deceased < Action
        def call
          @output.puts @view.deceased_table(@container.deceased_list.call)
        end
      end
    end
  end
end
