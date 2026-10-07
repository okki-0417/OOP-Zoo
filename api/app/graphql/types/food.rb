# frozen_string_literal: true

module Types
  class Food < BaseObject
    field :code, String, null: false
    field :name_ja, String, null: false
    field :category, FoodCategory, null: false
    field :satiety, Integer, null: false

    def code
      ::FoodCatalog.keys.find { |key| ::FoodCatalog.find(key) == object }.to_s
    end
  end
end
