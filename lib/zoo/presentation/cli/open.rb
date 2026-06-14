# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Open < Command
        def run(_args)
          dead = @container.open_for_a_day.call
          @output.puts "開園しました。死亡: #{dead.size}頭"
          @container.memorial_log.entries.last(dead.size).each { |entry| @output.puts "  #{entry}" }
        end
      end
    end
  end
end
