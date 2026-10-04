# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class ReleaseAnimalCommand < CommandFactory
    target ::Zoo::Application::Commands::ReleaseAnimalCommand

    defaults do |animals:, enclosures:, housings:, **|
      animal = build_adult(::Zoo::Domain::SpeciesCatalog.lion, name: 'レオ')
      enclosure = build_enclosure
      animals.save(animal)
      enclosures.save(enclosure)
      housings.save(housed(animal, enclosure))

      { animal_id: animal.id }
    end
  end
end
