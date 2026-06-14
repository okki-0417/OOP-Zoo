# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Report < Command
        CAUSE_LABELS = { old_age: '老衰', starvation: '餓死', illness: '病死', predation: '捕食', unknown: '不明' }.freeze

        def run(_args)
          stats = @container.zoo_report.call
          @output.puts "在園数: #{stats.population}頭（#{stats.species_count}種）"
          @output.puts "絶滅危惧種: #{stats.threatened_count}種"
          @output.puts "累計の誕生: #{stats.births}件"
          @output.puts "累計の死亡: #{format_deaths(stats.deaths_by_cause)}"
          @output.puts "累計収益: #{stats.revenue}"
        end

        private

        def format_deaths(deaths_by_cause)
          return '0件' if deaths_by_cause.empty?

          deaths_by_cause.map { |cause, count| "#{CAUSE_LABELS.fetch(cause, cause)}#{count}" }.join('・')
        end
      end
    end
  end
end
