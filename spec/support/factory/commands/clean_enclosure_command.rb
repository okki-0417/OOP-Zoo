# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class CleanEnclosureCommand < CommandFactory
    target ::Zoo::Application::Commands::CleanEnclosureCommand

    defaults do |keepers:, enclosures:, **|
      keeper = build_keeper
      enclosure = build_enclosure
      keepers.save(keeper)
      enclosures.save(enclosure)

      { keeper_id: keeper.id, enclosure_id: enclosure.id }
    end
  end
end
