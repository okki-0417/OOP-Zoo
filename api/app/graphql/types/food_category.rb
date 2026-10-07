# frozen_string_literal: true

module Types
  class FoodCategory < GraphQL::Schema::Enum
    ::Food::CATEGORIES.each { |category| value category.to_s.upcase, value: category }
  end
end
