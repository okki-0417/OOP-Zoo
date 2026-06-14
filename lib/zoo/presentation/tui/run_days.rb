# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class RunDays < Action
        def call
          days = @prompt.ask('進める日数:', convert: :int)

          summary = @container.run_days.call(Application::Commands::RunDaysCommand.new(days: days))
          @output.puts "#{summary.days}日経過。死亡 #{summary.total_deaths}頭"
        end
      end
    end
  end
end
