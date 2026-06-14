# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      # 動物福祉を評価するドメインサービス。
      #
      # 「1個体のその日のストレス増減」を、飼育環境(衛生・気候)と社会的状況(群れ性に
      # 対する孤独)、そして本人の状態(空腹・病気)から導く。ストレスの源が1つも無ければ
      # 良好な飼育とみなし、ストレスは回復に向かう。値はドメインサービスが計算し、
      # 蓄積は個体(Animal#add_stress / #relieve_stress)が担う。
      module Welfare
        module_function

        FILTH = 15            # 不衛生なエリア
        LONELINESS = 12       # 群れ性なのに仲間がいない
        CROWDING = 12         # 過密(体格の合計が広さを超える)
        CLIMATE_DISCOMFORT = 10 # 適温域の縁で快適でない
        HUNGER = 10           # 空腹
        ILLNESS = 12          # 病気
        RECOVERY = 15         # 良好な環境での回復量

        # その日のストレス増減を返す(正=増加、負=回復)。season は実効気温に影響する。
        def daily_stress(animal, enclosure, season: Operations::Season.spring)
          total = stressor_total(animal, enclosure, season)
          total.positive? ? total : -RECOVERY
        end

        # 群れ性の種なのに、同じエリアに同種の仲間がいない(=孤独)か。
        def lonely?(animal, enclosure)
          return false unless animal.species.group_living?

          companions = enclosure.occupants.count do |other|
            other.alive? && other.species.same_species?(animal.species)
          end
          companions <= 1 # 自分自身しかいない
        end

        def stressor_total(animal, enclosure, season)
          total = 0
          total += FILTH if enclosure.filthy?
          total += LONELINESS if lonely?(animal, enclosure)
          total += CROWDING if Stocking.overcrowded?(enclosure)
          total += CLIMATE_DISCOMFORT unless animal.species.comfortable?(season.felt_temperature(enclosure.temperature))
          total += HUNGER if animal.hungry?
          total += ILLNESS if animal.sick?
          total
        end
      end
    end
  end
end
