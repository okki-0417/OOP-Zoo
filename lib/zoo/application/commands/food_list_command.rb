# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      FoodListCommand = Data.define(:foods) do
        def initialize(foods: nil)
          super
        end

        def bind(foods:, **)
          with(foods:)
        end
      end
    end
  end
end
