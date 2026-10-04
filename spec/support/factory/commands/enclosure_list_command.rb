# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class EnclosureListCommand < CommandFactory
    target ::Zoo::Application::Commands::EnclosureListCommand
  end
end
