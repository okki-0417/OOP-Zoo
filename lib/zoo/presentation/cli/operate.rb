# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Operate < Command
        def run(_args)
          report = @container.operate_day.call
          @output.puts "来園 #{report.visitors}人 / 収入 #{report.income} / 費用 #{report.cost}"
          @output.puts "死亡 #{report.deaths}頭 / 評判 #{report.reputation} / 残高 #{report.balance}" \
                       "#{report.bankrupt ? '（赤字！）' : ''}"
        end
      end
    end
  end
end
