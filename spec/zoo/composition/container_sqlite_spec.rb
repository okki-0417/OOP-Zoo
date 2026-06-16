# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Container on SQLite (end-to-end)' do
  shared   = Zoo::Domain::Shared
  catalog  = Zoo::Domain::Taxonomy::SpeciesCatalog
  commands = Zoo::Application::Commands
  sex_male = Zoo::Domain::Animal::Sex.male

  it 'acquire→build-enclosure→house→operate の結果が別インスタンスでも永続化されること' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'zoo.db')

      container = Zoo::Composition::Container.new(database: path)
      enclosure = container.add_enclosure.call(
        commands::AddEnclosureCommand.new(name: 'サバンナ', temperature: shared::Temperature.celsius(30), capacity: 6)
      )
      zebra = container.acquire_animal.call(
        commands::AcquireAnimalCommand.new(species: catalog.grevys_zebra, name: 'シマオ', sex: sex_male, max_health: 100)
      )
      container.house_animal.call(
        commands::HouseAnimalCommand.new(enclosure_id: enclosure.id, animal_id: zebra.id)
      )
      container.operate_day.call

      reopened = Zoo::Composition::Container.new(database: path)

      expect(reopened.population.call).to eq(1)
      expect(reopened.animal_list.call.map(&:name)).to include('シマオ')
      expect(reopened.revenue.call.yen).to be >= 0
    end
  end
end
