# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Food < BaseObject
          field :code, String, null: false
          field :name_ja, String, null: false
          field :category, FoodCategory, null: false
          field :satiety, Integer, null: false

          def code
            Domain::FoodCatalog.keys.find { |key| Domain::FoodCatalog.find(key) == object }.to_s
          end
        end
      end
    end
  end
end
