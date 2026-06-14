# frozen_string_literal: true

module Zoo
  module Domain
    module Feeding
      # 給餌の「質」を評価するドメインサービス。
      #
      # 満腹度(量)とは別に、種の食性が求める餌カテゴリの多様性が満たされているかを見る。
      # 幅広い食性(雑食・草食)ほど多様な餌を要し、単一カテゴリの食性は1種で足りる。
      # 安全側に倒し、必要な多様性は最大2カテゴリまでとする。
      module NutritionPolicy
        module_function

        REQUIRED_VARIETY_CAP = 2

        # 与えた餌の組み合わせが、その種の栄養バランスを満たすか。
        def balanced?(species, foods)
          offered_categories(species, foods).size >= required_variety(species)
        end

        # この種が栄養充足に必要とする餌カテゴリ数。
        def required_variety(species)
          [species.diet_type.acceptable_categories.size, REQUIRED_VARIETY_CAP].min
        end

        # 与えた餌のうち、食性に合うものの異なるカテゴリ集合。
        def offered_categories(species, foods)
          diet = species.diet_type
          foods.select { |food| diet.accepts?(food.category) }
               .map(&:category)
               .uniq
        end
      end
    end
  end
end
