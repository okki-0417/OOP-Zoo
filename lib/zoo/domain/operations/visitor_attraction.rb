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

        def expected_visitors(animals, reputation)
          return 0 if animals.empty?

          species = animals.map(&:species).uniq
          appeal = (species.size * VARIETY_APPEAL) +
                   (species.count { |s| s.conservation_status.threatened? } * RARITY_APPEAL)
          appeal * reputation.score / Reputation::MAX
        end
      end
    end
  end
end
