# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class FoodList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:food_list) do
            @command.foods.all_by_code
          end
        end
      end
    end
  end
end
