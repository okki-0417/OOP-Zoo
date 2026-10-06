# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class NameAnimalCommand < CommandFactory
    target ::Zoo::Application::Commands::NameAnimalCommand

    defaults do |animals:, **|
      animal = build_animal(::Zoo::Domain::SpeciesCatalog.lion)
      animals.save(animal)

      { animal_id: animal.id, name: 'モモ' }
    end
  end
end
