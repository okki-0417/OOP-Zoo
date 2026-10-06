# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class FoodCategory < GraphQL::Schema::Enum
          Domain::Food::CATEGORIES.each { |category| value category.to_s.upcase, value: category }
        end
      end
    end
  end
end
