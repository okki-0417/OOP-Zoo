# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
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

        def advanced_by(days)
          raise ArgumentError, '進める日数は1以上でなければなりません' unless days.is_a?(Integer) && days >= 1

          self.class.new(@value + days)
        end

        def years
          @value / LifeStage::DAYS_PER_YEAR
        end

        def life_stage(species)
          LifeStage.for(age_in_days: @value, species: species)
        end

        def mature?(species)
          life_stage(species).mature?
        end

        WEANING_RATIO = 0.2

        def weaned?(species)
          weaning_days = (species.maturity_age_years * LifeStage::DAYS_PER_YEAR * WEANING_RATIO).floor
          @value >= weaning_days
        end

        def past_lifespan?(species)
          @value > species.lifespan_years * LifeStage::DAYS_PER_YEAR
        end

        BREEDING_SENESCENCE_RATIO = 0.8

        def past_breeding_age?(species)
          return false unless species.reproductively_senesces?

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
