# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class RunDaysCommand < CommandFactory
    target ::Zoo::Application::Commands::RunDaysCommand
    defaults { { days: 1 } }
  end
end
