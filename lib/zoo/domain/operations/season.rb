# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      class Season
        include Shared::ValueObject

        SEASONS = {
          spring: { label: '春', temperature_offset: 0 },
          summer: { label: '夏', temperature_offset: 8 },
          autumn: { label: '秋', temperature_offset: 0 },
          winter: { label: '冬', temperature_offset: -8 }
        }.freeze

        attr_reader :value

        SEASONS.each_key do |key|
          define_singleton_method(key) { new(key) }
        end

        def initialize(value)
          symbol = value.to_sym
          raise ArgumentError, "未知の季節です: #{value}" unless SEASONS.key?(symbol)

          @value = symbol
          freeze
        end

        def temperature_offset
          SEASONS.fetch(@value)[:temperature_offset]
        end

        def breeding_season?
          @value == :spring
        end

        def felt_temperature(base)
          Shared::Temperature.celsius(base.celsius + temperature_offset)
        end

        def label
          SEASONS.fetch(@value)[:label]
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
