# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class EnrichEnclosureCommand < CommandFactory
    target ::Zoo::Application::Commands::EnrichEnclosureCommand
  end
end
