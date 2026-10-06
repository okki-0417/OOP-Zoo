# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class HireKeeperCommand < CommandFactory
    target ::Zoo::Application::Commands::HireKeeperCommand
    defaults { { name: '田中', specialties: %w[mammal] } }
  end
end
