# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class HireVeterinarianCommand < CommandFactory
    target ::Zoo::Application::Commands::HireVeterinarianCommand
    defaults { { name: '佐藤' } }
  end
end
