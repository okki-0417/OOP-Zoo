# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      # 動物園の残高を表す不変の値オブジェクト。収益と支出の差。
      #
      # Money は非負(金額)だが、Balance は赤字(債務)を表せるよう符号を許す。
      # 0未満が破産のシグナルになる。
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

        def +(money)
          self.class.new(@yen + money.yen)
        end

        def -(money)
          self.class.new(@yen - money.yen)
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
