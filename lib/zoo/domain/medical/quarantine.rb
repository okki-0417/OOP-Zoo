# frozen_string_literal: true

module Zoo
  module Domain
    module Medical
      class Quarantine
        include Shared::ValueObject

        REQUIRED_DAYS = 30

        attr_reader :days_observed

        def self.begin
          new(0)
        end

        def initialize(days_observed)
          raise ArgumentError, '観察日数は0以上の整数でなければなりません' unless days_observed.is_a?(Integer) && !days_observed.negative?

          @days_observed = days_observed
          freeze
        end

        def observe(days)
          raise ArgumentError, '観察を進める日数は1以上でなければなりません' unless days.is_a?(Integer) && days >= 1

          self.class.new(@days_observed + days)
        end

        def period_complete?
          @days_observed >= REQUIRED_DAYS
        end

        def days_remaining
          [REQUIRED_DAYS - @days_observed, 0].max
        end

        def safe_to_release?(animal)
          period_complete? && !animal.sick?
        end

        protected

        def components
          [@days_observed]
        end
      end
    end
  end
end
