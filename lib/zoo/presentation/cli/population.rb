# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Population < Command
        def run(_args)
          @output.puts "在園数: #{@container.population.call}頭"
        end
      end
    end
  end
end
