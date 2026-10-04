# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class VeterinarianListCommand < CommandFactory
    target ::Zoo::Application::Commands::VeterinarianListCommand
  end
end
