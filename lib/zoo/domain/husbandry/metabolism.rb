# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      # 代謝と体格の知識を司るドメインサービス。
      #
      # 体重あたりの代謝(質量比代謝率)は小型ほど高く(おおむね M^-0.25)、
      # 絶対的な必要量・飼料費は大型ほど大きい(おおむね M^0.75)という生態学の
      # スケーリングに倣う。基準はライオン(190kg)で、空腹・満腹は従来値に一致させる。
      module Metabolism
        module_function

        REFERENCE_KG = 190.0 # ライオンを基準にする

        BASE_HUNGER_PER_DAY = 10
        HUNGER_MIN = 1
        HUNGER_MAX = 30

        FOOD_COST_REFERENCE_KG = 100.0
        # 実勢に合わせた飼料費(円/日)。肉はkg単価が草より大幅に高いため肉食係数を効かせ、
        # ライオン(190kg,肉食)≈2,500、ゾウ(大型,草食)≈8,500 と両端を現実圏に収める。
        FOOD_COST_BASE_YEN = 450
        FOOD_COST_MIN_YEN = 100
        PREDATORY_DIET_FACTOR = 3.5

        SATIETY_FACTOR_RANGE = (0.3..3.0)

        # 1日あたりに進む空腹度。小型・高代謝ほど速く空腹になる。
        def daily_hunger(species)
          factor = (REFERENCE_KG / species.adult_weight.kilograms)**0.25
          (BASE_HUNGER_PER_DAY * factor).round.clamp(HUNGER_MIN, HUNGER_MAX)
        end

        # この種が餌1単位から得る満腹度。小型ほどよく満たされ、大型はあまり満たされない。
        def satiety(species, food)
          factor = ((REFERENCE_KG / species.adult_weight.kilograms)**0.25).clamp(SATIETY_FACTOR_RANGE.begin, SATIETY_FACTOR_RANGE.end)
          [(food.satiety * factor).round, 1].max
        end

        # 1日あたりの飼料費。体格(絶対量)が大きいほど高く、肉食・魚食はさらに割高。
        def daily_food_cost(species)
          mass_factor = (species.adult_weight.kilograms / FOOD_COST_REFERENCE_KG)**0.75
          diet_factor = species.predatory? ? PREDATORY_DIET_FACTOR : 1.0
          yen = (FOOD_COST_BASE_YEN * mass_factor * diet_factor).round
          Shared::Money.yen([yen, FOOD_COST_MIN_YEN].max)
        end
      end
    end
  end
end
