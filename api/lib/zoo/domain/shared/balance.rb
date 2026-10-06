# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      class Balance
        include ValueObject

        attr_reader :yen

        def self.zero
          new(0)
        end

        def initialize(yen)
          raise ArgumentError, '残高は整数でなければなりません' unless yen.is_a?(Integer)

          @yen = yen
          freeze
        end

        def +(other)
          self.class.new(@yen + other.yen)
        end

        def -(other)
          self.class.new(@yen - other.yen)
        end

        def negative?
          @yen.negative?
        end

        def to_s
          sign = @yen.negative? ? '-' : ''
          "#{sign}¥#{@yen.abs.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
        end

        protected

        def components
          [@yen]
        end
      end
    end
  end
end
