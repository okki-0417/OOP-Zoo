# frozen_string_literal: true

module Zoo
  module Domain
    class Operating
      class Expense
        include Shared::ValueObject

        attr_reader :category, :subject, :quantity, :amount

        def initialize(category:, subject:, amount:, quantity: 1)
          raise ArgumentError, '費目の対象は必須です' if subject.to_s.empty?
          raise ArgumentError, '数量は1以上の整数でなければなりません' unless quantity.is_a?(Integer) && quantity.positive?

          @category = category
          @subject = subject
          @quantity = quantity
          @amount = amount
          freeze
        end

        def to_s
          counted = @quantity > 1 ? "#{@subject}×#{@quantity}" : @subject
          "#{@category} #{counted} #{@amount}"
        end

        protected

        def components
          [@category, @subject, @quantity, @amount]
        end
      end
    end
  end
end
