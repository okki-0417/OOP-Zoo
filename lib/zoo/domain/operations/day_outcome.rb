# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 1日のサイクル(DailyOperation)の結果を表すドメインの出力。
      # 永続化や表示用の整形はアプリケーション層が行う(read model への変換)。
      class DayOutcome
        attr_reader :visitors, :income, :cost, :deaths, :afflicted

        def initialize(visitors:, income:, cost:, deaths:, afflicted:)
          @visitors = visitors
          @income = income
          @cost = cost
          @deaths = deaths
          @afflicted = afflicted
          freeze
        end

        # その日に疫病で発病した個体の名前(無ければ nil)。
        def outbreak_name
          @afflicted&.name&.to_s
        end
      end
    end
  end
end
