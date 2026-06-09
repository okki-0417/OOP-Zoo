# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      # 生活史段階(ライフステージ)を表す値オブジェクト。
      #
      # 個体の日齢と、種ごとの性成熟年齢・寿命から導出する。
      # 繁殖可否(成体か)や展示・飼育方針の判断に用いる。
      class LifeStage
        include ValueObject

        DAYS_PER_YEAR = 365

        STAGES = { baby: '幼体', juvenile: '若齢', adult: '成体', elderly: '老齢' }.freeze

        attr_reader :value

        STAGES.each_key do |key|
          define_singleton_method(key) { new(key) }
        end

        # 日齢と種からライフステージを判定する。
        #   - 幼体: 性成熟年齢の半分未満
        #   - 若齢: 性成熟年齢の半分以上、性成熟年齢未満
        #   - 成体: 性成熟年齢以上、寿命の80%未満
        #   - 老齢: 寿命の80%以上
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

        # 繁殖可能な成熟段階(成体または老齢ではなく、成体)か。
        def adult?
          @value == :adult
        end

        def elderly?
          @value == :elderly
        end

        # 性成熟済み(成体以上)か。
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
