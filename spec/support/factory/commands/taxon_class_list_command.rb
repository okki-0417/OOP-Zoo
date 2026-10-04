# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class TaxonClassListCommand < CommandFactory
    target ::Zoo::Application::Commands::TaxonClassListCommand
  end
end
