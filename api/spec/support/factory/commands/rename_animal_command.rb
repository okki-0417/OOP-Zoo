# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class RenameAnimalCommand < CommandFactory
    target ::Zoo::Application::Commands::RenameAnimalCommand

    defaults do |animals:, **|
      animal = build_adult(::Zoo::Domain::SpeciesCatalog.lion, name: 'レオ')
      animals.save(animal)

      { animal_id: animal.id, new_name: 'モンキチ' }
    end
  end
end
