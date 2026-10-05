# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class ChecklistCommand < CommandFactory
    target ::Zoo::Application::Commands::ChecklistCommand
  end
end
