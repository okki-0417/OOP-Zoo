# frozen_string_literal: true

module Zoo
  module Domain
    class Operating < ApplicationRecord
      class Expense
        class Category
          include Shared::ValueObject

          VALUES = { payroll: '人件費', upkeep: '施設維持費', feed: '飼料費' }.freeze

          attr_reader :value

          def self.payroll
            new(:payroll)
          end

          def self.upkeep
            new(:upkeep)
          end

          def self.feed
            new(:feed)
          end

          def initialize(value)
            symbol = value.to_sym
            raise Errors::InvalidValue, "未知の費目です: #{value}" unless VALUES.key?(symbol)

            @value = symbol
            freeze
          end

          def label
            VALUES.fetch(@value)
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
end
