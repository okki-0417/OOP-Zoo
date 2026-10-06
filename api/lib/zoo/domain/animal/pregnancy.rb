# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class Pregnancy
        include Shared::ValueObject

        attr_reader :gestation_days, :sex, :inbreeding_coefficient

        def self.conceived(inbreeding: 0.0)
          new(sex: Sex.random, gestation_days: 0, inbreeding_coefficient: inbreeding)
        end

        def initialize(sex:, gestation_days: 0, inbreeding_coefficient: 0.0)
          valid_days = gestation_days.is_a?(Integer) && !gestation_days.negative?
          raise ArgumentError, '妊娠日数は0以上の整数でなければなりません' unless valid_days

          @sex = sex
          @gestation_days = gestation_days
          @inbreeding_coefficient = inbreeding_coefficient
          freeze
        end

        def advanced_by(days)
          raise ArgumentError, '経過日数は0以上でなければなりません' if days.negative?

          self.class.new(
            sex: @sex,
            gestation_days: @gestation_days + days,
            inbreeding_coefficient: @inbreeding_coefficient
          )
        end

        def to_s
          "妊娠#{@gestation_days}日"
        end

        protected

        def components
          [@sex, @gestation_days, @inbreeding_coefficient]
        end
      end
    end
  end
end
