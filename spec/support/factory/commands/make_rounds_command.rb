# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class MakeRoundsCommand < CommandFactory
    target ::Zoo::Application::Commands::MakeRoundsCommand
  end
end
