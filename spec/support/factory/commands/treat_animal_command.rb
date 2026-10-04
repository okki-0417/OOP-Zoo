# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class TreatAnimalCommand < CommandFactory
    target ::Zoo::Application::Commands::TreatAnimalCommand

    defaults do |veterinarians:, animals:, **|
      veterinarian = ::Zoo::Domain::Veterinarian.new(name: '佐藤')
      animal = build_adult(::Zoo::Domain::SpeciesCatalog.lion, name: 'レオ')
      veterinarians.save(veterinarian)
      animals.save(animal)

      { veterinarian_id: veterinarian.id, animal_id: animal.id }
    end
  end
end
