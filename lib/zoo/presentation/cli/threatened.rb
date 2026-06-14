# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Threatened < Command
        def run(_args)
          rows = @container.threatened_species.call
          if rows.empty?
            @output.puts '展示中の絶滅危惧種はいません'
          else
            rows.each { |row| @output.puts "#{row.name_ja}（#{row.status_code}/#{row.status_label}）: #{row.count}頭" }
          end
        end
      end
    end
  end
end
