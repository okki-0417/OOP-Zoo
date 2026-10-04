# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class PopulationCommand < CommandFactory
    target ::Zoo::Application::Commands::PopulationCommand
  end
end
