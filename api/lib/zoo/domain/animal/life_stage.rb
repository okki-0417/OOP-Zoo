# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class LifeStage
        include Shared::ValueObject

        DAYS_PER_YEAR = 365

        STAGES = { baby: '幼体', juvenile: '若齢', adult: '成体', elderly: '老齢' }.freeze

        attr_reader :value

        STAGES.each_key do |key|
          define_singleton_method(key) { new(key) }
        end

        def self.for(age_in_days:, species:)
          maturity_days = species.maturity_age_years * DAYS_PER_YEAR
          elderly_days = species.lifespan_years * DAYS_PER_YEAR * 0.8

          value =
            if age_in_days >= elderly_days then :elderly
            elsif age_in_days >= maturity_days then :adult
            elsif age_in_days >= maturity_days / 2.0 then :juvenile
            else :baby
            end

          new(value)
        end

        def initialize(value)
          symbol = value.to_sym
          raise ArgumentError, "未知のライフステージです: #{value}" unless STAGES.key?(symbol)

          @value = symbol
          freeze
        end

        def baby?
          @value == :baby
        end

        def adult?
          @value == :adult
        end

        def elderly?
          @value == :elderly
        end

        def mature?
          %i[adult elderly].include?(@value)
        end

        def label
          STAGES.fetch(@value)
        end

        def to_s
          label
        end

        protected

        def components
          [@value]
        end
      end
    end
  end
end
