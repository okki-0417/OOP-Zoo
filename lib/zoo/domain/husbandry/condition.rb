# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      # 来園者が知覚する「飼育の質」=コンディション(0〜100)を算出するドメインサービス。
      #
      # 動物の真の状態ではなく、客に見える分だけ。健康で落ち着いて見えるか。清潔・過密・刺激・
      # 栄養は直接ではなく、福祉(ストレス)・健康を介してここに現れる(チェーンの中間集約)。
      # コンディションは体験(VisitorExperience)の入力になり、体験を通じて評判を動かす。
      module Condition
        module_function

        NEUTRAL = 50
        STRESSED_PENALTY = 40
        SICK_PENALTY = 40
        WEAK_PENALTY = 20

        # 在園(生存)個体の平均コンディション。個体がいなければ中立(50)。
        def score(animals)
          living = animals.select(&:alive?)
          return NEUTRAL if living.empty?

          living.sum { |animal| individual_score(animal) } / living.size
        end

        # 1個体の見えるコンディション。健康で落ち着いていれば100、不調ほど低い。
        def individual_score(animal)
          score = 100
          score -= STRESSED_PENALTY if animal.stressed?
          score -= SICK_PENALTY if animal.sick?
          score -= WEAK_PENALTY if animal.health.weak?
          [score, 0].max
        end
      end
    end
  end
end
