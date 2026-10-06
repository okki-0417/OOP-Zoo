# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class TransferAnimalCommand < CommandFactory
    target ::Zoo::Application::Commands::TransferAnimalCommand

    defaults do |animals:, enclosures:, **|
      animal = build_adult(::Zoo::Domain::SpeciesCatalog.lion, name: 'レオ')
      enclosure = build_enclosure
      animals.save(animal)
      enclosures.save(enclosure)

      { animal_id: animal.id, enclosure_id: enclosure.id }
    end
  end
end
