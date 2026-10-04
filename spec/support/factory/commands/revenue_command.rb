# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class RevenueCommand < CommandFactory
    target ::Zoo::Application::Commands::RevenueCommand
  end
end
