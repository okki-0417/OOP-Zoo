# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      # 栄養状態を表す不変の値オブジェクト。0(栄養失調)〜100(良好)。
      #
      # 満腹度(量)とは別の軸で、食性に見合った多様な餌を与えられているか(質)を表す。
      # バランスの取れた食事で改善し、偏った食事で悪化する。一定以下で栄養失調とみなす。
      class Nutrition
        include Shared::ValueObject
        include Comparable

        MIN = 0
        MAX = 100
        MALNOURISHED_THRESHOLD = 30

        attr_reader :level

        def self.nourished
          new(MAX)
        end

        def initialize(level)
          raise ArgumentError, '栄養状態は整数でなければなりません' unless level.is_a?(Integer)

          @level = level.clamp(MIN, MAX)
          freeze
        end

        def improved_by(amount)
          raise ArgumentError, '改善量は0以上でなければなりません' if amount.negative?

          self.class.new(@level + amount)
        end

        def declined_by(amount)
          raise ArgumentError, '悪化量は0以上でなければなりません' if amount.negative?

          self.class.new(@level - amount)
        end

        def malnourished?
          @level <= MALNOURISHED_THRESHOLD
        end

        def <=>(other)
          return nil unless other.is_a?(Nutrition)

          @level <=> other.level
        end

        def to_s
          "#{@level}/#{MAX}"
        end

        protected

        def components
          [@level]
        end
      end
    end
  end
end
