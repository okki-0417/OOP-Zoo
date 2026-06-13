# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      # 性別を表す値オブジェクト。繁殖の可否判定などで用いる。
      class Sex
        include Shared::ValueObject

        VALUES = { male: 'オス', female: 'メス' }.freeze

        attr_reader :value

        def self.male
          new(:male)
        end

        def self.female
          new(:female)
        end

        def initialize(value)
          symbol = value.to_sym
          raise ArgumentError, "未知の性別です: #{value}" unless VALUES.key?(symbol)

          @value = symbol
          freeze
        end

        def male?
          @value == :male
        end

        def female?
          @value == :female
        end

        # 繁殖は雌雄の組でのみ成立する。相手が異性かを判定する。
        def opposite?(other)
          other.is_a?(Sex) && @value != other.value
        end

        def label
          VALUES.fetch(@value)
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
