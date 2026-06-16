# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
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
