# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class DischargeKeeperCommand < CommandFactory
    target ::Zoo::Application::Commands::DischargeKeeperCommand

    defaults do |keepers:, enclosures:, assignments:, **|
      keeper = build_keeper
      enclosure = build_enclosure
      keepers.save(keeper)
      enclosures.save(enclosure)
      assignments.save(::Zoo::Domain::Tending.new(keeper:, enclosure:))

      { keeper_id: keeper.id, enclosure_id: enclosure.id }
    end
  end
end
