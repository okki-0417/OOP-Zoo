# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class ExpenseCategory < GraphQL::Schema::Enum
          Domain::Operating::Expense::Category::VALUES.each_key do |category|
            value category.to_s.upcase, value: category
          end
        end
      end
    end
  end
end
