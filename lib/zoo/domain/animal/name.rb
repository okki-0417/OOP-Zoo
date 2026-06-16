# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
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
