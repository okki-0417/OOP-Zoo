# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemoryFoodRepository
        include Domain::Repositories::FoodRepository

        def find(code)
          Domain::FoodCatalog.find(code)
        end

        def all_by_code
          Domain::FoodCatalog.keys.to_h { |code| [code, Domain::FoodCatalog.find(code)] }
        end
      end
    end
  end
end
