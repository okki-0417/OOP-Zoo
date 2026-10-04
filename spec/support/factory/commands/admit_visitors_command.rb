# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class AdmitVisitorsCommand < CommandFactory
    target ::Zoo::Application::Commands::AdmitVisitorsCommand
    defaults { { count: 10 } }
  end
end
