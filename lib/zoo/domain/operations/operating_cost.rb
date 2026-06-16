# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 1日の運営コストを算出するドメインサービス。
      # エリアの維持費・職員の給与・在園個体の飼料費(体格・食性で変動)の合計。
      module OperatingCost
        module_function

        # 1日あたりの実勢ベンチに合わせた値(円)。
        # 維持費: 展示1つ年~180万、空調館の電気代、飼育員 年収~360万÷~300日。
        UPKEEP_PER_ENCLOSURE = 5_000
        CLIMATE_CONTROL_RUNNING_YEN = 4_000
        SALARY_PER_STAFF = 12_000

        # enclosures: 飼育エリア(Enclosure)の配列。空調付きは稼働費が上乗せされる。
        # species: 在園個体の種(Species)の配列。飼料費は種ごとの代謝から算出する。
        def daily(enclosures:, staff:, species:)
          upkeep = enclosures.sum(0) { |e| UPKEEP_PER_ENCLOSURE + (e.climate_controlled? ? CLIMATE_CONTROL_RUNNING_YEN : 0) }
          salaries = SALARY_PER_STAFF * staff
          food = species.sum(0) { |s| Husbandry::Metabolism.daily_food_cost(s).yen }
          Shared::Money.yen(upkeep + salaries + food)
        end
      end
    end
  end
end
