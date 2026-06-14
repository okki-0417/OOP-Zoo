# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      # 飼育密度(ストッキング)を判断するドメインサービス。
      #
      # 収容個体それぞれが体格に応じて面積を必要とし、その合計が区画の広さを超えると
      # 過密(overcrowded)とみなす。頭数の上限(定員)とは別の軸で、体格の大きな動物を
      # 詰め込むと過密になる。
      module Stocking
        module_function

        # 収容個体が必要とする面積の合計(m²)。
        def required_area(enclosure)
          enclosure.occupants.sum { |animal| animal.species.space_requirement_sqm }
        end

        # 過密か(必要面積の合計が区画の広さを超えるか)。
        def overcrowded?(enclosure)
          required_area(enclosure) > enclosure.area_sqm
        end
      end
    end
  end
end
