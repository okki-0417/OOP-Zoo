# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class OperateDayCommand < CommandFactory
    target ::Zoo::Application::Commands::OperateDayCommand
    defaults { { random: Random.new(0) } }
  end
end
