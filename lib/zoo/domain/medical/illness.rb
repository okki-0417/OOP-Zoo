# frozen_string_literal: true

module Zoo
  module Domain
    module Medical
      # 病気・怪我を表す値オブジェクト。
      #
      # 毎日体力を削る度合い(daily_damage)と、同居個体へうつるか(contagious)を持つ。
      # 重症度は daily_damage の大きさで表現する。
      class Illness
        include Shared::ValueObject

        attr_reader :name_ja, :daily_damage

        def initialize(name_ja:, daily_damage:, contagious: false)
          raise ArgumentError, '病名は必須です' if name_ja.to_s.empty?
          raise ArgumentError, '進行ダメージは1以上でなければなりません' unless daily_damage.is_a?(Integer) && daily_damage.positive?

          @name_ja = name_ja
          @daily_damage = daily_damage
          @contagious = contagious
          freeze
        end

        # 同居個体に感染するか。
        def contagious?
          @contagious
        end

        # 重症(進行が速い)か。
        def severe?
          @daily_damage >= 5
        end

        def to_s
          @name_ja
        end

        protected

        def components
          [@name_ja, @daily_damage, @contagious]
        end
      end
    end
  end
end
