# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 展示内容・評判・話題・福祉から、その日の期待来園者数を算出するドメインサービス。
      #
      # 集客 = f(魅力, 評判, 料金)。状態を持たない純粋な関数。
      # 魅力(appeal) … カリスマ性＋多様性＋話題(buzz)。「何が見られるか」。
      # 評判(reputation) … 運営の質・信用。集客の母数(Qmax)と支払意思(Pmax)を押し上げる。
      #
      # 需要は線形: 来園(p) = Qmax × max(0, 1 − p/Pmax)。
      #   Qmax … 無料なら来る最大客数（魅力 × 評判）
      #   Pmax … 支払意思の上限(choke price)。これ以上の料金では誰も来ない
      # 収益(料金 × 来園)は上に凸となり、最適料金 ≒ Pmax/2 が存在する（単位弾力ではない）。
      module VisitorAttraction
        module_function

        VARIETY_APPEAL = 20
        # 支払意思(choke price)の下限と、魅力1点あたりの押し上げ額(評判満点時)。
        WILLINGNESS_BASE_YEN = 3_000
        WILLINGNESS_PER_APPEAL_YEN = 15
        # 全頭がストレス下にあるときの集客係数(良好なら1.0)。
        WELFARE_FLOOR = 0.5

        def expected_visitors(animals, reputation, admission_fee, buzz: 0)
          return 0 if animals.empty?

          appeal = appeal_of(animals, buzz)
          q_max = max_demand(appeal, reputation)
          p_max = willingness_to_pay(appeal, reputation)
          price = admission_fee.yen
          return 0 if price >= p_max

          visitors = q_max * (1.0 - (price.to_f / p_max))
          (visitors * welfare_multiplier(animals)).to_i
        end

        # 魅力: カリスマ性＋多様性＋話題。
        def appeal_of(animals, buzz = 0)
          species = animals.map(&:species).uniq
          species.sum(&:charisma) + (species.size * VARIETY_APPEAL) + buzz
        end

        # 無料時の最大客数(Qmax)。魅力と評判の積。
        def max_demand(appeal, reputation)
          appeal * reputation.score / Reputation::MAX
        end

        # 支払意思の上限(Pmax/choke price)。良い園(魅力・評判が高い)ほど高くても来る。
        def willingness_to_pay(appeal, reputation)
          WILLINGNESS_BASE_YEN + (appeal * WILLINGNESS_PER_APPEAL_YEN * reputation.score / Reputation::MAX)
        end

        # 福祉による集客係数。ストレスを抱えていない個体の割合が高いほど1.0に近づく。
        def welfare_multiplier(animals)
          return 1.0 if animals.empty?

          content = animals.count { |animal| !animal.stressed? }
          WELFARE_FLOOR + ((1.0 - WELFARE_FLOOR) * content.to_f / animals.size)
        end
      end
    end
  end
end
