# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class ZooReportCommand < CommandFactory
    target ::Zoo::Application::Commands::ZooReportCommand
  end
end
