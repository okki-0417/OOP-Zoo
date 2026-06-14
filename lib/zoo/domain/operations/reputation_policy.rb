# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 1日の運営結果から評判の増減を決めるドメインサービス。
      # 死亡が出ると評判を下げ、無事に過ごせた日は少し上げる。
      module ReputationPolicy
        module_function

        DEATH_PENALTY = 5
        HEALTHY_BONUS = 2

        def after_day(reputation, deaths:)
          return reputation.lose(DEATH_PENALTY * deaths) if deaths.positive?

          reputation.gain(HEALTHY_BONUS)
        end
      end
    end
  end
end
