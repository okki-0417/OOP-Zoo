# frozen_string_literal: true

class Operating < ApplicationRecord
  class Expense
    include ValueObject

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

    def self.from_h(hash)
      new(
        category: Category.new(hash.fetch('category')), subject: hash.fetch('subject'),
        quantity: hash.fetch('quantity'), amount: Money.yen(hash.fetch('amount'))
      )
    end

    def to_h
      { category: @category.value.to_s, subject: @subject, quantity: @quantity, amount: @amount.yen }
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
