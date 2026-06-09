# frozen_string_literal: true

module Zoo
  module Domain
    module Medical
      # 代表的な疾病のカタログ。
      module IllnessCatalog
        module_function

        def cold
          Illness.new(name_ja: '風邪', daily_damage: 2, contagious: true)
        end

        def parasite
          Illness.new(name_ja: '寄生虫感染', daily_damage: 3, contagious: true)
        end

        def pneumonia
          Illness.new(name_ja: '肺炎', daily_damage: 6, contagious: true)
        end

        def fracture
          Illness.new(name_ja: '骨折', daily_damage: 4, contagious: false)
        end

        def all
          %i[cold parasite pneumonia fracture].map { |name| public_send(name) }
        end
      end
    end
  end
end
