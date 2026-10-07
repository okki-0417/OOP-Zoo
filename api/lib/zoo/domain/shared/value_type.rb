# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      class ValueType < ActiveModel::Type::Value
        def initialize(value_class, dump:, load: value_class.method(:new))
          super()
          @value_class = value_class
          @load = load
          @dump = dump
        end

        def cast(value)
          return value if value.nil? || value.is_a?(@value_class)

          @load.call(value)
        end

        def serialize(value)
          value.nil? ? nil : @dump.call(cast(value))
        end
      end
    end
  end
end
