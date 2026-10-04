# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class AnimalListCommand < CommandFactory
    target ::Zoo::Application::Commands::AnimalListCommand
  end
end
