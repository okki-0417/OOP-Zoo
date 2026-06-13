# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      # 個体名を表す値オブジェクト。1文字以上の文字列を保持する。
      class Name
        include Shared::ValueObject

        attr_reader :value

        def initialize(value)
          raise ArgumentError, '名前は一文字以上でなければなりません' if value.to_s.empty?

          @value = value.to_s
          freeze
        end

        def to_s
          @value
        end

        protected

        def components
          [@value]
        end
      end
    end
  end
end
