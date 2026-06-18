# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ListFoods < Action
        def call(_params)
          catalog = Domain::FoodCatalog
          [200, catalog.keys.map { |key| Serializer.food_ref(key, catalog.find(key)) }]
        end
      end
    end
  end
end
