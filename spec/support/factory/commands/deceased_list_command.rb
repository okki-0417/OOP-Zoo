# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class DeceasedListCommand < CommandFactory
    target ::Zoo::Application::Commands::DeceasedListCommand
  end
end
