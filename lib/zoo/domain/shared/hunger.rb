# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      # 空腹度を表す不変の値オブジェクト。0(満腹)〜100(限界)。
      #
      # 時間経過で増加し、給餌で減少する。一定以上で「空腹」、上限で「飢餓」とみなし、
      # 飢餓状態は体力を削る要因になる。
      class Hunger
        include ValueObject
        include Comparable

        MIN = 0
        MAX = 100
        HUNGRY_THRESHOLD = 70

        attr_reader :level

        def self.satisfied
          new(MIN)
        end

        def initialize(level)
          raise ArgumentError, '空腹度は整数でなければなりません' unless level.is_a?(Integer)

          @level = level.clamp(MIN, MAX)
          freeze
        end

        def increased_by(amount)
          raise ArgumentError, '増加量は0以上でなければなりません' if amount.negative?

          self.class.new(@level + amount)
        end

        def decreased_by(amount)
          raise ArgumentError, '減少量は0以上でなければなりません' if amount.negative?

          self.class.new(@level - amount)
        end

        # 空腹か(しきい値以上)。
        def hungry?
          @level >= HUNGRY_THRESHOLD
        end

        # 飢餓状態(限界)か。
        def starving?
          @level >= MAX
        end

        # 満腹か。
        def satisfied?
          @level == MIN
        end

        def <=>(other)
          return nil unless other.is_a?(Hunger)

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
