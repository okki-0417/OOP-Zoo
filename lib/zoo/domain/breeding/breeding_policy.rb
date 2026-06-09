# frozen_string_literal: true

module Zoo
  module Domain
    module Breeding
      # 繁殖の可否を判断するドメインサービス。
      #
      # 動物個体としての繁殖適性(同種・異性・成熟・健康)に加え、近親交配を避ける
      # という飼育下の遺伝管理ルールを課す。親子・きょうだいは繁殖させない。
      module BreedingPolicy
        module_function

        def can_mate?(a, b)
          rejection_reason(a, b).nil?
        end

        # 近親(親子またはきょうだい)か。
        def related?(a, b)
          a.parent_of?(b) || b.parent_of?(a) || a.sibling_of?(b)
        end

        # 繁殖できない理由(可能ならnil)。
        def rejection_reason(a, b)
          return '同種・異性・成熟・健康な個体同士でなければ繁殖できません' unless a.can_breed_with?(b)
          return '近親交配は避ける必要があります' if related?(a, b)

          nil
        end
      end
    end
  end
end
