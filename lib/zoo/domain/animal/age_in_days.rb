# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      # 個体の日齢(年齢を日数で表したもの)を表す不変の値オブジェクト。
      #
      # 値そのものの正当性(0以上の整数)に加え、種(Species)と組み合わせた
      # 派生情報(ライフステージ・成熟・寿命超過・年齢)を提供する。
      # 加齢は新しいインスタンスを返すことで不変性を保つ。
      class AgeInDays
        include Shared::ValueObject
        include Comparable

        attr_reader :value

        def self.zero
          new(0)
        end

        def initialize(value)
          raise ArgumentError, '日齢は0以上の整数でなければなりません' unless value.is_a?(Integer) && !value.negative?

          @value = value
          freeze
        end

        # 指定日数ぶん進めた新しいAgeInDaysを返す。
        def advanced_by(days)
          raise ArgumentError, '進める日数は1以上でなければなりません' unless days.is_a?(Integer) && days >= 1

          self.class.new(@value + days)
        end

        # 端数切り捨ての年齢(歳)。
        def years
          @value / LifeStage::DAYS_PER_YEAR
        end

        # 指定種に対するライフステージ。
        def life_stage(species)
          LifeStage.for(age_in_days: @value, species: species)
        end

        # 指定種に対して性成熟しているか。
        def mature?(species)
          life_stage(species).mature?
        end

        # 離乳適齢(性成熟年齢の2割)に達し、親に依存しなくなったか。
        WEANING_RATIO = 0.2

        def weaned?(species)
          weaning_days = (species.maturity_age_years * LifeStage::DAYS_PER_YEAR * WEANING_RATIO).floor
          @value >= weaning_days
        end

        # 指定種の寿命を超えているか。
        def past_lifespan?(species)
          @value > species.lifespan_years * LifeStage::DAYS_PER_YEAR
        end

        # 繁殖適齢期の上限を過ぎ、生殖が老化したか(寿命の8割を超えた高齢)。
        BREEDING_SENESCENCE_RATIO = 0.8

        def past_breeding_age?(species)
          @value >= species.lifespan_years * BREEDING_SENESCENCE_RATIO * LifeStage::DAYS_PER_YEAR
        end

        def <=>(other)
          return nil unless other.is_a?(AgeInDays)

          @value <=> other.value
        end

        def to_s
          @value.to_s
        end

        protected

        def components
          [@value]
        end
      end
    end
  end
end
