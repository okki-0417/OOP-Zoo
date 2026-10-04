# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class HouseAnimalCommand < CommandFactory
    target ::Zoo::Application::Commands::HouseAnimalCommand

    defaults do |enclosures:, animals:, **|
      enclosure = build_enclosure
      animal = build_adult(::Zoo::Domain::SpeciesCatalog.lion, name: 'レオ')
      enclosures.save(enclosure)
      animals.save(animal)

      { enclosure_id: enclosure.id, animal_id: animal.id }
    end
  end
end
