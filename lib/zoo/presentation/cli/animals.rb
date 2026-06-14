# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Animals < Command
        def run(_args)
          rows = @container.animal_list.call
          if rows.empty?
            @output.puts '個体はいません'
          else
            rows.each { |row| @output.puts "#{row.id}  #{row.name}（#{row.species}）#{row.alive ? '' : '[死亡]'}" }
          end
        end
      end
    end
  end
end
