# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class Pregnancy
        include Shared::ValueObject

        attr_reader :sire_id, :gestation_days

        def self.conceived(sire_id)
          new(sire_id: sire_id, gestation_days: 0)
        end

        def initialize(sire_id:, gestation_days: 0)
          raise ArgumentError, '父個体の識別子が必要です' if sire_id.nil?

          valid_days = gestation_days.is_a?(Integer) && !gestation_days.negative?
          raise ArgumentError, '妊娠日数は0以上の整数でなければなりません' unless valid_days

          @sire_id = sire_id
          @gestation_days = gestation_days
          freeze
        end

        def advanced_by(days)
          raise ArgumentError, '経過日数は0以上でなければなりません' if days.negative?

          self.class.new(sire_id: @sire_id, gestation_days: @gestation_days + days)
        end

        def to_s
          "妊娠#{@gestation_days}日"
        end

        protected

        def components
          [@sire_id, @gestation_days]
        end
      end
    end
  end
end
