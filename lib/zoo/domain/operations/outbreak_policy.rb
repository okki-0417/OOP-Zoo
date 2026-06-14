# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # その日に疫病が発生するかを判定するドメインサービス。
      # 一定確率で、健康な在園個体のうち1頭が発病する(誰が、は乱数源に委ねる)。
      # 乱数源を引数で受けることで、確率ルールは保ちつつテストを決定的にできる。
      module OutbreakPolicy
        module_function

        CHANCE_PERCENT = 20

        # 発病する個体を返す(発生しなければ nil)。
        def strike(animals, random)
          healthy = animals.select { |animal| animal.alive? && !animal.sick? }
          return nil if healthy.empty?
          return nil unless random.rand(100) < CHANCE_PERCENT

          healthy[random.rand(healthy.size)]
        end
      end
    end
  end
end
