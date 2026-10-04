# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class EnclosureDetailCommand < CommandFactory
    target ::Zoo::Application::Commands::EnclosureDetailCommand

    defaults do |enclosures:, **|
      enclosure = build_enclosure
      enclosures.save(enclosure)

      { enclosure_id: enclosure.id }
    end
  end
end
