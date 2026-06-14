# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class OperateDay < Action
        def call
          @output.puts @view.day_report(@container.operate_day.call)
        end
      end
    end
  end
end
