# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Zoo::Composition::Container 永続化' do
  shared = Zoo::Domain::Shared
  catalog   = Zoo::Domain::SpeciesCatalog
  commands  = Zoo::Application::Commands

  it 'save→load で在園・収益・収容関係が復元され、復元後も同一性が保たれること' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'zoo.save')

      original = Zoo::Composition::Container.new
      enclosure = original.add_enclosure.call(
        commands::AddEnclosureCommand.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
      )
      lion = original.acquire_animal.call(
        commands::AcquireAnimalCommand.new(species: catalog.lion, name: 'レオ',
                                           sex: Zoo::Domain::Animal::Sex.male, max_health: 100)
      )
      original.house_animal.call(commands::HouseAnimalCommand.new(enclosure_id: enclosure.id, animal_id: lion.id))
      original.admit_visitors.call(commands::AdmitVisitorsCommand.new(count: 10))
      original.save(path)

      restored = Zoo::Composition::Container.load(path)

      expect(restored.population.call).to eq(1)
      expect(restored.revenue.call).to eq(shared::Money.yen(20_000))

      occupancy = Zoo::Domain::Occupancy.new(restored.housings.all)
      resident = occupancy.occupants_of(restored.enclosures.all.first).first
      expect(restored.animals.find(resident.id)).to equal(resident)
    end
  end
end
