# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      # 体力(HP)を表す不変の値オブジェクト。
      #
      # 現在値と最大値の組で体力を表現し、増減は常に新しいHealthを返す。
      # 0未満や最大値超過にならないことを内部で保証するため、利用側は
      # 範囲チェックを意識しなくてよい。
      class Health
        include Shared::ValueObject

        # この割合以下を「衰弱状態」とみなす既定のしきい値。
        DEFAULT_WEAK_THRESHOLD = 0.2

        attr_reader :current, :max

        # 最大体力で満タンのHealthを生成する。
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

        # 体力を減らした新しいHealthを返す(0未満にはならない)。
        def decreased_by(amount)
          raise ArgumentError, '減少量は0以上でなければなりません' if amount.negative?

          with_current(@current - amount)
        end

        # 体力を回復した新しいHealthを返す(最大値を超えない)。
        def increased_by(amount)
          raise ArgumentError, '回復量は0以上でなければなりません' if amount.negative?

          with_current(@current + amount)
        end

        # 現在体力の割合(0.0〜1.0)。
        def ratio
          @current.to_f / @max
        end

        # 衰弱しているか(既定では20%以下)。
        def weak?(threshold = DEFAULT_WEAK_THRESHOLD)
          ratio <= threshold
        end

        # 体力が尽きているか。
        def empty?
          @current.zero?
        end

        # 満タンか。
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
