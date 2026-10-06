# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class Health
        include Shared::ValueObject

        DEFAULT_WEAK_THRESHOLD = 0.2

        attr_reader :current, :max

        def self.full(max)
          new(current: max, max: max)
        end

        def initialize(current:, max:)
          raise ArgumentError, '最大体力は1以上でなければなりません' unless max.is_a?(Integer) && max.positive?
          raise ArgumentError, '現在体力は整数でなければなりません' unless current.is_a?(Integer)

          @max = max
          @current = current.clamp(0, max)
          freeze
        end

        def decreased_by(amount)
          raise ArgumentError, '減少量は0以上でなければなりません' if amount.negative?

          with_current(@current - amount)
        end

        def increased_by(amount)
          raise ArgumentError, '回復量は0以上でなければなりません' if amount.negative?

          with_current(@current + amount)
        end

        def ratio
          @current.to_f / @max
        end

        def weak?(threshold = DEFAULT_WEAK_THRESHOLD)
          ratio <= threshold
        end

        def empty?
          @current.zero?
        end

        def full?
          @current == @max
        end

        def to_s
          "#{@current}/#{@max}"
        end

        protected

        def components
          [@current, @max]
        end

        private

        def with_current(value)
          self.class.new(current: value, max: @max)
        end
      end
    end
  end
end
