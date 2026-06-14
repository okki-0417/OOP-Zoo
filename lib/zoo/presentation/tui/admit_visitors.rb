# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class AdmitVisitors < Action
        def call
          count = @prompt.ask('来園者数:', convert: :int)

          revenue = @container.admit_visitors.call(
            Application::Commands::AdmitVisitorsCommand.new(count: count)
          )
          @output.puts "来園を受け入れました。累計収益: #{revenue}"
        end
      end
    end
  end
end
