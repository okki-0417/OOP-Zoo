# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class Report < Action
        def call
          @output.puts @view.report(@container.zoo_report.call)
        end
      end
    end
  end
end
