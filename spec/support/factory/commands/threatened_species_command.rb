# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class ThreatenedSpeciesCommand < CommandFactory
    target ::Zoo::Application::Commands::ThreatenedSpeciesCommand
  end
end
