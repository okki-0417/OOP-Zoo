# frozen_string_literal: true

module Types
  class Expense < BaseObject
    field :category, ExpenseCategory, null: false
    field :subject, String, null: false
    field :quantity, Integer, null: false
    field :amount, Integer, null: false

    def category
      object.category.value
    end

    def amount
      object.amount.yen
    end
  end
end
