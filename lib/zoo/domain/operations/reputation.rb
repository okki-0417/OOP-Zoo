# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 動物園の評判を表す不変の値オブジェクト(0〜100)。来園者数に影響する。
      #
      # 内部は連続値(value)で保持する。1日の評判ドリフトは露出が小さいと1点未満になるため、
      # 整数で丸めると小さな前進が毎日消えてフリーズする。連続値で持ち、端数を翌日へ累積する。
      # 表示・需要計算には丸めた整数 score を使う。
      class Reputation
        include Shared::ValueObject
        include Comparable

        MIN = 0
        MAX = 100

        attr_reader :value

        def self.default
          new(50)
        end

        def initialize(value)
          raise ArgumentError, '評判は数値でなければなりません' unless value.is_a?(Numeric)

          @value = value.clamp(MIN, MAX).to_f
          freeze
        end

        # 表示・需要計算用の整数評判(0〜100)。
        def score
          @value.round
        end

        def gain(amount)
          self.class.new(@value + amount)
        end

        def lose(amount)
          self.class.new(@value - amount)
        end

        def <=>(other)
          return nil unless other.is_a?(Reputation)

          @value <=> other.value
        end

        def to_s
          "#{score}/#{MAX}"
        end

        protected

        def components
          [@value]
        end
      end
    end
  end
end
