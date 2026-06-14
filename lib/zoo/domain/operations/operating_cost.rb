# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 1日の運営コストを算出するドメインサービス。
      # エリアの維持費・職員の給与・個体ごとの飼料費の合計。
      module OperatingCost
        module_function

        UPKEEP_PER_ENCLOSURE = 1_000
        SALARY_PER_STAFF = 3_000
        FOOD_PER_ANIMAL = 500

        def daily(enclosures:, animals:, staff:)
          yen = (UPKEEP_PER_ENCLOSURE * enclosures) +
                (SALARY_PER_STAFF * staff) +
                (FOOD_PER_ANIMAL * animals)
          Shared::Money.yen(yen)
        end
      end
    end
  end
end
