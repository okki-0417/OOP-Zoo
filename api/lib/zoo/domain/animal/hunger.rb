# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class Hunger
        include Shared::ValueObject
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

        def hungry?
          @level >= HUNGRY_THRESHOLD
        end

        def starving?
          @level >= MAX
        end

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
