# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Revenue < Command
        def run(_args)
          @output.puts "累計収益: #{@container.revenue.call}"
        end
      end
    end
  end
end
