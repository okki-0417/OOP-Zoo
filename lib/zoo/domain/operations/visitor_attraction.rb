# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 展示内容・評判・話題・福祉から、その日の期待来園者数を算出するドメインサービス。
      #
      # 集客は種の希少性そのものではなく、カリスマ性(フラッグシップ種)と多様性が生む。
      # 福祉の悪い(ストレスを抱えた)動物の多い展示は魅力を損ない、幼獣誕生などの話題は
      # 一時的に集客を押し上げる。評判と入園料が全体を増減させる。
      module VisitorAttraction
        module_function

        VARIETY_APPEAL = 20
        # この料金を中立点とし、これより高いと来園者が減り、安いと増える。
        BASELINE_FEE_YEN = 2_000
        # 全頭がストレス下にあるときの集客係数(良好なら1.0)。
        WELFARE_FLOOR = 0.5

        def expected_visitors(animals, reputation, admission_fee, buzz: 0)
          return 0 if animals.empty?

          species = animals.map(&:species).uniq
          appeal = species.sum(&:charisma) + (species.size * VARIETY_APPEAL) + buzz
          base = appeal * reputation.score * BASELINE_FEE_YEN / (Reputation::MAX * admission_fee.yen)
          (base * welfare_multiplier(animals)).to_i
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
