# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class Stress
        include Shared::ValueObject
        include Comparable

        MIN = 0
        MAX = 100
        STRESSED_THRESHOLD = 60
        SEVERE_THRESHOLD = 90

        attr_reader :level

        def self.calm
          new(MIN)
        end

        def initialize(level)
          raise ArgumentError, 'ストレス度は整数でなければなりません' unless level.is_a?(Integer)

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

        def stressed?
          @level >= STRESSED_THRESHOLD
        end

        def severe?
          @level >= SEVERE_THRESHOLD
        end

        def calm?
          @level == MIN
        end

        def <=>(other)
          return nil unless other.is_a?(Stress)

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
