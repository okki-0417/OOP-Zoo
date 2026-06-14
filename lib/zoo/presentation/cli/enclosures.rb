# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Enclosures < Command
        def run(_args)
          rows = @container.enclosure_list.call
          if rows.empty?
            @output.puts 'エリアはありません'
          else
            rows.each { |row| @output.puts "#{row.id}  #{row.name}（#{row.population}/#{row.capacity}）" }
          end
        end
      end
    end
  end
end
