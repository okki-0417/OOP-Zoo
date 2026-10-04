# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class AssignKeeperCommand < CommandFactory
    target ::Zoo::Application::Commands::AssignKeeperCommand

    defaults do |keepers:, enclosures:, **|
      keeper = build_keeper
      enclosure = build_enclosure
      keepers.save(keeper)
      enclosures.save(enclosure)

      { keeper_id: keeper.id, enclosure_id: enclosure.id }
    end
  end
end
