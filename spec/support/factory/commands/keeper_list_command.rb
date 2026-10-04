# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class KeeperListCommand < CommandFactory
    target ::Zoo::Application::Commands::KeeperListCommand
  end
end
