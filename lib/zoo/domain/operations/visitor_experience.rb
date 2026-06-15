# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 来園した人が感じた「その日の体験の質」(0〜100)を算出するドメインサービス。
      #
      # 体験 = g(コンディション, 料金との釣り合い)。コンディション(知覚される飼育の質)を、
      # 料金が作る期待のレンズ越しに見たもの。同じ見えでも、高い料金ほど「これだけ払ったのに」と
      # 期待が上がり満足は下がる(期待ギャップ)。混雑・見せ場(可視性)も体験を左右するが後段(未実装)。
      # 体験は評判のドリフト先(アトラクター)になる。
      module VisitorExperience
        module_function

        # 入園料 ¥FEE_PER_EXPECTATION ごとに期待が1点上がり、その分だけ満足を割り引く。
        FEE_PER_EXPECTATION = 500

        def score(condition:, fee:)
          (condition - expectation_penalty(fee)).clamp(0, 100)
        end

        # 料金が生む期待。高いほど満足の基準が上がる。
        def expectation_penalty(fee)
          fee.yen / FEE_PER_EXPECTATION
        end
      end
    end
  end
end
