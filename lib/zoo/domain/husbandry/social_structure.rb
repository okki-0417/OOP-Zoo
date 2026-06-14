# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      # 群れの社会構造(序列)を判断するドメインサービス。
      #
      # 群れで暮らす種は、成熟したオスの間に序列ができ、優位な1頭(ここでは最年長)以外の
      # 成熟オスは序列下位の「余剰オス」として闘争のストレスを受ける。バチェラー(独身オス)を
      # 別に分けるべき、という飼育判断につながる。
      module SocialStructure
        module_function

        # この個体が、同じエリアの序列下位の成熟オス(=余剰オス)か。
        def subordinate_male?(animal, enclosure)
          return false unless contender?(animal)

          rivals = enclosure.occupants.select { |other| contender?(other) && same_group?(other, animal) }
          return false if rivals.size < 2

          dominant = rivals.max_by { |male| male.age_in_days.value }
          animal.id != dominant.id
        end

        # 序列を争う立場(生存・成熟・オス・群れ性)か。
        def contender?(animal)
          animal.alive? && animal.sex.male? && animal.mature? && animal.species.group_living?
        end

        def same_group?(other, animal)
          other.species.same_species?(animal.species)
        end
      end
    end
  end
end
