# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 展示内容と評判から、その日の期待来園者数を算出するドメインサービス。
      # 展示種の多様性と希少種(絶滅危惧種)が魅力を生み、評判がそれを増減させる。
      module VisitorAttraction
        module_function

        VARIETY_APPEAL = 20
        RARITY_APPEAL = 30
        # この料金を中立点とし、これより高いと来園者が減り、安いと増える。
        BASELINE_FEE_YEN = 2_000

        def expected_visitors(animals, reputation, admission_fee)
          return 0 if animals.empty?

          species = animals.map(&:species).uniq
          appeal = (species.size * VARIETY_APPEAL) +
                   (species.count { |s| s.conservation_status.threatened? } * RARITY_APPEAL)
          appeal * reputation.score * BASELINE_FEE_YEN / (Reputation::MAX * admission_fee.yen)
        end
      end
    end
  end
end
