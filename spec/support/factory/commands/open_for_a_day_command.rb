# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class OpenForADayCommand < CommandFactory
    target ::Zoo::Application::Commands::OpenForADayCommand
  end
end
