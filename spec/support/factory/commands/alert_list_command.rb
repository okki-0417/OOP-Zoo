# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class AlertListCommand < CommandFactory
    target ::Zoo::Application::Commands::AlertListCommand
  end
end
