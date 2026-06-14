# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Deceased < Command
        CAUSE_LABELS = { old_age: '老衰', starvation: '餓死', illness: '病死', predation: '捕食', unknown: '不明' }.freeze

        def run(_args)
          records = @container.deceased_list.call
          if records.empty?
            @output.puts '死亡記録はありません'
          else
            records.each { |r| @output.puts "#{r.name}（#{r.species}）#{CAUSE_LABELS.fetch(r.cause, r.cause)}" }
          end
        end
      end
    end
  end
end
