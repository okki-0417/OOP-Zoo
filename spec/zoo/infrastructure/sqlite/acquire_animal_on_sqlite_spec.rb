# frozen_string_literal: true

require 'spec_helper'

# AcquireAnimal ユースケースを SQLite 実装の上で動かす(ポート差し替えの実証)。
RSpec.describe 'AcquireAnimal on SQLite' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  sqlite  = Zoo::Infrastructure::Sqlite

  it '実トランザクションで個体を受け入れ、永続化されること' do
    database = sqlite::Database.new
    animals = sqlite::AnimalRepository.new(database)
    service = Zoo::Application::Services::AcquireAnimal.new(
      animals: animals, unit_of_work: sqlite::UnitOfWork.new(database)
    )

    animal = service.call(
      Zoo::Application::Commands::AcquireAnimalCommand.new(
        species: catalog.lion, name: 'レオ', sex: Zoo::Domain::Animal::Sex.male, max_health: 100
      )
    )

    expect(animals.find(animal.id).name.to_s).to eq('レオ')
    expect(animals.all.size).to eq(1)
  end
end
