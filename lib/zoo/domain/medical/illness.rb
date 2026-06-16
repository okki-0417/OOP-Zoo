# frozen_string_literal: true

module Zoo
  module Domain
    module Medical
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

        def contagious?
          @contagious
        end

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
