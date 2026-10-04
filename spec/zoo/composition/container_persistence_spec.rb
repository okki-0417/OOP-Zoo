# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Zoo::Composition::Container 永続化' do
  shared   = Zoo::Domain::Shared
  commands = Zoo::Application::Commands
  passthrough = Zoo::Presentation::Renderers::Passthrough

  it 'save→load で在園・収益・収容関係が復元され、復元後も同一性が保たれること' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'zoo.save')

      original = Zoo::Composition::Container.new
      enclosure = original.add_enclosure(
        commands::AddEnclosureCommand.new(name: 'ライオンの丘', celsius: 28, capacity: 4), renderer: passthrough
      ).value
      lion = original.acquire_animal(
        commands::AcquireAnimalCommand.new(species_code: 'lion', name: 'レオ', sex: 'male'), renderer: passthrough
      ).value
      original.house_animal(
        commands::HouseAnimalCommand.new(enclosure_id: enclosure.id, animal_id: lion.id), renderer: passthrough
      )
      original.admit_visitors(commands::AdmitVisitorsCommand.new(count: 10), renderer: passthrough)
      original.save(path)

      restored = Zoo::Composition::Container.load(path)

      expect(restored.population(commands::PopulationCommand.new, renderer: passthrough).value).to eq(1)
      expect(restored.revenue(commands::RevenueCommand.new, renderer: passthrough).value).to eq(shared::Money.yen(20_000))

      resident = restored.housings.occupants_of(restored.enclosures.all.first).first
      expect(restored.animals.find(resident.id)).to equal(resident)
    end
  end
end
