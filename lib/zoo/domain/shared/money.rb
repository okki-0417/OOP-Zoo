# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      class Money
        include ValueObject
        include Comparable

        attr_reader :yen

        def self.zero
          new(0)
        end

        def self.yen(amount)
          new(amount)
        end

        def initialize(yen)
          raise ArgumentError, '金額は整数でなければなりません' unless yen.is_a?(Integer)
          raise ArgumentError, '金額は0以上でなければなりません' if yen.negative?

          @yen = yen
          freeze
        end

        def +(other)
          self.class.new(@yen + other.yen)
        end

        def *(factor)
          raise ArgumentError, '係数は0以上の整数でなければなりません' unless factor.is_a?(Integer) && !factor.negative?

          self.class.new(@yen * factor)
        end

        def <=>(other)
          return nil unless other.is_a?(Money)

          @yen <=> other.yen
        end

        def to_s
          "¥#{@yen.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
        end

        protected

        def components
          [@yen]
        end
      end
    end
  end
end
