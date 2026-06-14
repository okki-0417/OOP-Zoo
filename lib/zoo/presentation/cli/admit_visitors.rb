# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class AdmitVisitors < Command
        def run(args)
          count, = args
          raise ArgumentError, '使い方: admit-visitors COUNT' if count.nil?

          command = Application::Commands::AdmitVisitorsCommand.new(count: Integer(count))
          revenue = @container.admit_visitors.call(command)
          @output.puts "来園者を受け入れました。累計収益: #{revenue}"
        end
      end
    end
  end
end
