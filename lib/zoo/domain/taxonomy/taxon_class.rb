# frozen_string_literal: true

module Zoo
  module Domain
    module Taxonomy
      # 生物分類の「綱(class)」を表す値オブジェクト。
      #
      # 恒温/変温、胎生/卵生といった綱に固有の性質を持ち、
      # 繁殖方法(出産か産卵か)や飼育環境の判断に用いる。
      class TaxonClass
        include Shared::ValueObject

        CLASSES = {
          mammal: { label: '哺乳類', warm_blooded: true, reproduction: :viviparous },
          bird: { label: '鳥類', warm_blooded: true, reproduction: :oviparous },
          reptile: { label: '爬虫類', warm_blooded: false, reproduction: :oviparous },
          amphibian: { label: '両生類', warm_blooded: false, reproduction: :oviparous },
          fish: { label: '魚類', warm_blooded: false, reproduction: :oviparous },
          invertebrate: { label: '無脊椎動物', warm_blooded: false, reproduction: :oviparous }
        }.freeze

        attr_reader :value

        CLASSES.each_key do |key|
          define_singleton_method(key) { new(key) }
        end

        def initialize(value)
          symbol = value.to_sym
          raise ArgumentError, "未知の綱です: #{value}" unless CLASSES.key?(symbol)

          @value = symbol
          freeze
        end

        # 恒温動物か。
        def warm_blooded?
          CLASSES.fetch(@value)[:warm_blooded]
        end

        # 変温動物か。
        def cold_blooded?
          !warm_blooded?
        end

        # 胎生(出産)か。
        def viviparous?
          CLASSES.fetch(@value)[:reproduction] == :viviparous
        end

        # 卵生(産卵)か。
        def oviparous?
          !viviparous?
        end

        def label
          CLASSES.fetch(@value)[:label]
        end

        def to_s
          label
        end

        protected

        def components
          [@value]
        end
      end
    end
  end
end
