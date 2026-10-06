# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class AddEnclosureCommand < CommandFactory
    target ::Zoo::Application::Commands::AddEnclosureCommand
    defaults { { name: '猿山', celsius: 20, capacity: 5 } }
  end
end
