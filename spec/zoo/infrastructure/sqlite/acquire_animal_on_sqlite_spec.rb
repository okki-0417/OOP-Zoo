# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AcquireAnimal on SQLite' do
  sqlite = Zoo::Infrastructure::Sqlite

  it '実トランザクションで個体を受け入れ、永続化されること' do
    database = sqlite::Database.new
    animals = sqlite::AnimalRepository.new(database)
    zoo = sqlite::ZooRepository.new(
      database,
      Zoo::Domain::Zoo.new(
        name: 'テスト動物園', admission_fee: Zoo::Domain::Shared::Money.yen(2_000),
        funds: Zoo::Domain::Shared::Money.yen(100_000)
      )
    )
    command = Zoo::Application::Commands::AcquireAnimalCommand.new(species_code: 'lion', name: 'レオ', sex: 'male').bind(
      animals: animals, species: Zoo::Infrastructure::InMemory::InMemorySpeciesRepository.new, zoo: zoo,
      unit_of_work: sqlite::UnitOfWork.new(database)
    )

    animal = Zoo::Application::Services::AcquireAnimal.new(command: command).call.value[:animal]

    expect(animals.find(animal.id).name.to_s).to eq('レオ')
    expect(animals.all.size).to eq(1)
  end
end
