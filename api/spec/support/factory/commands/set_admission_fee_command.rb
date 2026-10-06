# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class SetAdmissionFeeCommand < CommandFactory
    target ::Zoo::Application::Commands::SetAdmissionFeeCommand
    defaults { { fee: 2_000 } }
  end
end
