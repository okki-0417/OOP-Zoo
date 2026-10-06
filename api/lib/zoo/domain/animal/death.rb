# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class Death
        include Shared::ValueObject

        CAUSE_LABELS = {
          old_age: '老衰', starvation: '餓死', illness: '病死',
          predation: '捕食', malnutrition: '栄養失調', injury: '外傷', unknown: '不明'
        }.freeze

        attr_reader :cause

        def initialize(cause: :unknown)
          raise ArgumentError, "無効な原因: #{cause}" unless CAUSE_LABELS.key?(cause)

          @cause = cause
          freeze
        end

        def to_s
          CAUSE_LABELS.fetch(@cause, @cause.to_s)
        end

        protected

        def components
          [@cause]
        end
      end
    end
  end
end
