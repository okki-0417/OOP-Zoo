# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class RunDays < Command
        def run(args)
          days, = args
          raise ArgumentError, '使い方: run-days DAYS' if days.nil?

          summary = @container.run_days.call(Application::Commands::RunDaysCommand.new(days: Integer(days)))
          @output.puts "#{summary.days}日経過。死亡: #{summary.total_deaths}頭"
        end
      end
    end
  end
end
