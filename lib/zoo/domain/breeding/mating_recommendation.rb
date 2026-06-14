# frozen_string_literal: true

module Zoo
  module Domain
    module Breeding
      # 個体群の遺伝管理として、次に組ませるべき繁殖ペアを推奨するドメインサービス。
      #
      # 近親(親子・きょうだい)を避けたうえで、生まれる子の近交係数が最も低くなる
      # (= 両親の近縁度が最も低い)組み合わせを選び、遺伝的多様性の損失を最小化する。
      # 個体は親を id でしか知らないため、id→個体 を引く lookup を受け取る。
      module MatingRecommendation
        module_function

        # 候補集団から推奨ペア [sire, dam] を返す。組める相手がいなければ nil。
        def recommend(animals, lookup)
          candidate_pairs(animals)
            .min_by { |sire, dam| Pedigree.inbreeding_of_offspring(sire, dam, lookup) }
        end

        # 繁殖可能な(同種・異性・成熟・健康・非近親の)雌雄ペアの一覧。
        def candidate_pairs(animals)
          males = animals.select { |a| a.sex.male? }
          females = animals.select { |a| a.sex.female? }

          males.product(females).select { |sire, dam| BreedingPolicy.can_mate?(sire, dam) }
        end
      end
    end
  end
end
