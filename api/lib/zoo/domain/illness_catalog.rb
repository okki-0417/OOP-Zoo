# frozen_string_literal: true

module Zoo
  module Domain
    module IllnessCatalog
      module_function

      def cold
        Animal::Illness.new(name_ja: '風邪', daily_damage: 2, contagious: true)
      end

      def parasite
        Animal::Illness.new(name_ja: '寄生虫感染', daily_damage: 3, contagious: true)
      end

      def pneumonia
        Animal::Illness.new(name_ja: '肺炎', daily_damage: 6, contagious: true)
      end

      def fracture
        Animal::Illness.new(name_ja: '骨折', daily_damage: 4, contagious: false)
      end

      KEYS = %i[cold parasite pneumonia fracture].freeze

      def keys
        KEYS
      end

      def all
        KEYS.map { |name| public_send(name) }
      end

      def find(key)
        symbol = key.to_s.to_sym
        return nil unless KEYS.include?(symbol)

        public_send(symbol)
      end
    end
  end
end
