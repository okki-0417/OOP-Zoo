# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class AcquireAnimalCommand < CommandFactory
    target ::Zoo::Application::Commands::AcquireAnimalCommand
    defaults { { species_code: 'japanese_macaque', name: 'モンタ', sex: 'male' } }
  end
end
