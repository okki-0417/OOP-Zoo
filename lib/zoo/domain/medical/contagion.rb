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

        # エリア内で感染を広げ、新たに発病した個体を返す。
        def spread(enclosure)
          illnesses = active_contagions(enclosure)
          return [] if illnesses.empty?

          enclosure.occupants.each_with_object([]) do |animal, infected|
            next unless susceptible?(animal)

            illness = illnesses.find { |ill| !animal.immune_to?(ill) }
            next unless illness

            animal.fall_ill(illness)
            infected << animal
          end
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
