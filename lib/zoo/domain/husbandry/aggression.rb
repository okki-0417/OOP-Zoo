# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      # 種内闘争による外傷を判断するドメインサービス。
      #
      # 群れの序列下位の余剰オスは闘争の的になり、負傷する。過密や逃げ場(隠れ場所)の
      # 不足は闘争を激化させ、負傷を深くする。十分な広さと刺激があれば和らぐ。
      module Aggression
        module_function

        BASE_INJURY = 5
        CROWDING_AGGRAVATION = 5  # 過密で逃げ場がない
        NO_REFUGE_AGGRAVATION = 5 # 殺風景で隠れ場所がない

        # その日に被る外傷の大きさ(体力減)。闘争の的でなければ0。
        def injury_for(animal, enclosure)
          return 0 unless SocialStructure.subordinate_male?(animal, enclosure)

          injury = BASE_INJURY
          injury += CROWDING_AGGRAVATION if Stocking.overcrowded?(enclosure)
          injury += NO_REFUGE_AGGRAVATION if enclosure.barren?
          injury
        end
      end
    end
  end
end
