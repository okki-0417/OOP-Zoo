# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class SpeciesListCommand < CommandFactory
    target ::Zoo::Application::Commands::SpeciesListCommand
  end
end
