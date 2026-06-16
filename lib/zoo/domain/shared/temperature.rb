# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      class Temperature
        include ValueObject
        include Comparable

        attr_reader :celsius

        def self.celsius(value)
          new(value)
        end

        def initialize(celsius)
          raise ArgumentError, '気温は数値でなければなりません' unless celsius.is_a?(Numeric)
          raise ArgumentError, '気温は絶対零度(-273.15℃)を下回れません' if celsius < -273.15

          @celsius = celsius.to_f
          freeze
        end

        def fahrenheit
          @celsius * 9 / 5 + 32
        end

        def within?(range)
          range.cover?(self)
        end

        def <=>(other)
          return nil unless other.is_a?(Temperature)

          @celsius <=> other.celsius
        end

        def to_s
          format('%.1f℃', @celsius)
        end

        protected

        def components
          [@celsius]
        end
      end
    end
  end
end
