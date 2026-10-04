# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class FoodListCommand < CommandFactory
    target ::Zoo::Application::Commands::FoodListCommand
  end
end
