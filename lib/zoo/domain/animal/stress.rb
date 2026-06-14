# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      # ストレス(心理的福祉の度合い)を表す不変の値オブジェクト。0(穏やか)〜100(限界)。
      #
      # 飼育環境や社会的状況が悪いと日々増し、良ければ和らぐ。一定以上で「ストレス状態」、
      # 限界近くで「過度のストレス」とみなし、過度のストレスは免疫を下げて体力を削る。
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

        # ストレス状態(しきい値以上)か。
        def stressed?
          @level >= STRESSED_THRESHOLD
        end

        # 過度のストレス(限界近く)か。免疫低下の要因になる。
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
