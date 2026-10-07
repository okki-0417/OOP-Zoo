# frozen_string_literal: true

module Types
  class ExpenseCategory < GraphQL::Schema::Enum
    ::Operating::Expense::Category::VALUES.each_key do |category|
      value category.to_s.upcase, value: category
    end
  end
end
