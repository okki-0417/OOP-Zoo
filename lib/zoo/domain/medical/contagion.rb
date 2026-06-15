# frozen_string_literal: true

module Zoo
  module Domain
    module Medical
      # 接触感染を扱うドメインサービス。
      #
      # 接触の単位は同一飼育エリア。感染性(contagious)の病気を持つ個体がいると、同じエリアの
      # 健康で免疫のない個体に広がる。誰がどの病気にかかるかは個体の免疫で決まる。
      module Contagion
        module_function

        BASE_CHANCE = 50
        FILTH_BONUS = 30
        CROWDING_BONUS = 20

        # エリア内で感染を広げ、新たに発病した個体を返す。
        # random を与えると接触の度合い(transmission_chance)に応じて確率的に伝播する。
        # 与えなければ決定論的に(感受性のある全個体へ)広がる。
        def spread(enclosure, random: nil)
          illnesses = active_contagions(enclosure)
          return [] if illnesses.empty?

          chance = transmission_chance(enclosure)
          enclosure.occupants.each_with_object([]) do |animal, infected|
            next unless susceptible?(animal)

            illness = illnesses.find { |ill| !animal.immune_to?(ill) }
            next unless illness
            next if random && random.rand(100) >= chance

            animal.fall_ill(illness)
            infected << animal
          end
        end

        # 接触感染の確率(%)。不衛生・過密なエリアほど高い。
        def transmission_chance(enclosure)
          chance = BASE_CHANCE
          chance += FILTH_BONUS if enclosure.filthy?
          chance += CROWDING_BONUS if Husbandry::Stocking.overcrowded?(enclosure)
          [chance, 100].min
        end

        # エリア内で出回っている感染性の病気(重複なし)。
        def active_contagions(enclosure)
          enclosure.occupants
                   .select { |a| a.alive? && a.sick? && a.illness.contagious? }
                   .map(&:illness)
                   .uniq
        end

        def susceptible?(animal)
          animal.alive? && !animal.sick?
        end
      end
    end
  end
end
