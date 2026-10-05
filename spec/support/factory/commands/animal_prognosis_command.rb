# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class AnimalPrognosisCommand < CommandFactory
    target ::Zoo::Application::Commands::AnimalPrognosisCommand

    defaults do |animals:, **|
      animal = build_adult(::Zoo::Domain::SpeciesCatalog.lion, name: 'レオ')
      animals.save(animal)

      { animal_id: animal.id }
    end
  end
end
