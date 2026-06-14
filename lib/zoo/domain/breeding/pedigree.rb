# frozen_string_literal: true

module Zoo
  module Domain
    module Breeding
      # 血統(系図)から近縁度・近交係数を導く遺伝管理のドメインサービス。
      #
      # 個体は親を id でしか知らないため、id→個体 を引く lookup(呼び出し可能オブジェクト)を
      # 受け取り、祖先をたどって計算する。lookup が nil を返す祖先(在籍記録から消えた等)は、
      # 創始個体(他と血縁なし)として扱う。
      #
      # 近縁度 f(coancestry, Malécot) は再帰で定義する:
      #   f(X, X) = 1/2 (1 + F_X)            … F_X は X の近交係数
      #   f(X, Y) = 1/2 (f(父X, Y) + f(母X, Y))  … X を「より新しい(若い)側」に選んで展開
      #   創始個体(親が辿れない) … 自分以外との f は 0
      # 個体 Z の近交係数 F_Z は、両親の近縁度 f(父Z, 母Z) に等しい。
      module Pedigree
        module_function

        # 2個体の近縁度(coancestry)。0(無縁)〜。
        def kinship(a, b, lookup)
          return 0.0 if a.nil? || b.nil?
          return 0.5 * (1.0 + inbreeding_coefficient(a, lookup)) if a.id == b.id

          younger, other = order_by_age(a, b)
          parents = parents_of(younger, lookup)
          return 0.0 if parents.empty? # 創始個体は他と無縁

          0.5 * parents.sum { |parent| kinship(parent, other, lookup) }
        end

        # 個体の近交係数 F。両親の近縁度に等しい(親が辿れなければ0)。
        def inbreeding_coefficient(animal, lookup)
          parents = parents_of(animal, lookup)
          return 0.0 if parents.size < 2

          kinship(parents[0], parents[1], lookup)
        end

        # この親ペアから生まれる子の近交係数(= 両親の近縁度)。
        def inbreeding_of_offspring(sire, dam, lookup)
          kinship(sire, dam, lookup)
        end

        # 集団の平均近縁度。小さいほど遺伝的に多様。
        def mean_kinship(animals, lookup)
          pairs = animals.combination(2).to_a
          return 0.0 if pairs.empty?

          pairs.sum { |a, b| kinship(a, b, lookup) } / pairs.size
        end

        def parents_of(animal, lookup)
          animal.parent_ids.map { |id| lookup.call(id) }.compact
        end

        # 親(より古い個体)を descendant 側へ展開しないよう、若い方を先に返す。
        def order_by_age(a, b)
          a.age_in_days.value <= b.age_in_days.value ? [a, b] : [b, a]
        end
      end
    end
  end
end
