# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Composition::Container do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  commands  = Zoo::Application::Commands

  let(:container) { described_class.new }

  it 'acquire→house を同一コンテナで実行すると、共有リポジトリ越しに population に反映されること' do
    lion = container.acquire_animal.call(
      commands::AcquireAnimalCommand.new(species: catalog.lion, name: 'レオ',
                                         sex: Zoo::Domain::Animal::Sex.male, max_health: 100)
    )
    enclosure = container.enclosures.save(
      husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
    )

    container.house_animal.call(commands::HouseAnimalCommand.new(enclosure_id: enclosure.id, animal_id: lion.id))

    expect(container.population.call).to eq(1)
  end

  it 'conceive を実行すると、配線された dam が妊娠状態になること' do
    sire, dam = build_pair(catalog.lion)
    container.animals.save(sire)
    container.animals.save(dam)

    container.conceive_animals.call(
      commands::ConceiveAnimalsCommand.new(sire_id: sire.id, dam_id: dam.id)
    )

    expect(container.animals.find(dam.id)).to be_expecting
  end

  it 'deliver を実行すると、配線された購読者(birth_announcements)に通知が届くこと' do
    sire, dam = build_pair(catalog.lion)
    container.animals.save(sire)
    dam.conceive(sire_id: sire.id)
    catalog.lion.gestation_period_days.times { dam.gestate }
    container.animals.save(dam)
    enclosure = container.enclosures.save(
      husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
    )

    container.deliver_animal.call(
      commands::DeliverAnimalCommand.new(dam_id: dam.id, enclosure_id: enclosure.id)
    )

    expect(container.birth_announcements.announcements.size).to eq(1)
  end
end
