# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 動物園の評判を表す不変の値オブジェクト(0〜100)。来園者数に影響する。
      class Reputation
        include Shared::ValueObject
        include Comparable

        MIN = 0
        MAX = 100

        attr_reader :score

        def self.default
          new(50)
        end

        def initialize(score)
          raise ArgumentError, '評判は整数でなければなりません' unless score.is_a?(Integer)

          @score = score.clamp(MIN, MAX)
          freeze
        end

        def gain(amount)
          self.class.new(@score + amount)
        end

        def lose(amount)
          self.class.new(@score - amount)
        end

        def <=>(other)
          return nil unless other.is_a?(Reputation)

          @score <=> other.score
        end

        def to_s
          "#{@score}/#{MAX}"
        end

        protected

        def components
          [@score]
        end
      end
    end
  end
end
