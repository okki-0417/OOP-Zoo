# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class OperatingHistoryCommand < CommandFactory
    target ::Zoo::Application::Commands::OperatingHistoryCommand
  end
end
