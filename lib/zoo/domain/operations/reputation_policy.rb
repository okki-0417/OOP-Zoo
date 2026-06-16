# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 1日の運営結果から評判(ストック)の増減を決めるドメインサービス。
      #
      # 評判は「公衆が抱く、その園の質への蓄積された信念」。二つの経路でしか動かない:
      #   体験経路   … 来た人が感じた体験へ評判がゆっくりドリフトする。口コミなので
      #                来場規模(露出)が大きいほど強く動き、誰も来なければ動かない。
      #   ニュース経路 … 死亡・疫病など来てない人にも届く出来事。露出によらず即時に動く。
      # ニュースは ReputationEvent(各出来事が自分の reputation_delta を持つ)として渡す。
      # ドリフトは非対称: 信用は築くより失うほうが速い(下げ幅は上げ幅の DOWN_MULTIPLIER 倍まで)。
      module ReputationPolicy
        module_function

        # 1日に「上げられる」最大幅(築くは遅い)。下げはこの DOWN_MULTIPLIER 倍まで。
        DRIFT_CAP = 3
        DOWN_MULTIPLIER = 2
        # この来場規模で口コミが社会に行き渡る(露出が満杯=係数1.0)とみなす。社会側のしきい値で
        # あり、園の収容力とは無関係。expected_visitors のスケールに合わせて調整する定数で、
        # 需要を作り直したら見直す。小集客の日は前進が1点未満になるが、Reputation が端数を累積
        # するのでフリーズせず"遅くなる"だけ(=世論は持続的な人気で初めて動く)。
        EXPOSURE_REFERENCE = 2_000

        def after_day(reputation, experience:, exposure: 0, events: [])
          value = reputation.value
          value += drift(experience, value, exposure)
          value += events.sum(&:reputation_delta)
          Reputation.new(value)
        end

        # 体験へ向かうドリフト。露出(来場規模)で強さが決まり、下降は上昇より速い。
        # 端数は丸めず返す(Reputation 側で累積する)。
        def drift(experience, value, exposure)
          gap = experience - value
          cap = gap.negative? ? DRIFT_CAP * DOWN_MULTIPLIER : DRIFT_CAP
          gap.clamp(-cap, cap) * exposure_factor(exposure)
        end

        # 露出係数(0〜1)。来場が多いほど口コミが行き渡り、1.0に近づく。
        def exposure_factor(exposure)
          return 0.0 unless exposure.positive?

          [exposure.to_f / EXPOSURE_REFERENCE, 1.0].min
        end
      end
    end
  end
end
