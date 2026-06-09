# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      # 気温・体温を表す不変の値オブジェクト(摂氏)。
      #
      # 飼育エリアの気候適合(寒帯の動物を熱帯エリアに入れない等)や、
      # 動物の体調管理で用いる。
      class Temperature
        include ValueObject
        include Comparable

        attr_reader :celsius

        def self.celsius(value)
          new(value)
        end

        def initialize(celsius)
          raise ArgumentError, '気温は数値でなければなりません' unless celsius.is_a?(Numeric)
          raise ArgumentError, '気温は絶対零度(-273.15℃)を下回れません' if celsius < -273.15

          @celsius = celsius.to_f
          freeze
        end

        def fahrenheit
          @celsius * 9 / 5 + 32
        end

        # 指定範囲(Range of Temperature)に収まるか。
        def within?(range)
          range.cover?(self)
        end

        def <=>(other)
          return nil unless other.is_a?(Temperature)

          @celsius <=> other.celsius
        end

        def to_s
          format('%.1f℃', @celsius)
        end

        protected

        def components
          [@celsius]
        end
      end
    end
  end
end
