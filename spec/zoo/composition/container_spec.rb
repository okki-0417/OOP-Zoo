# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Composition::Container do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  commands  = Zoo::Application::Commands

  let(:container) { described_class.new }

  def run(use_case, command)
    container.public_send(use_case, command)
  end

  it 'acquire_animal→house_animal を同一コンテナで実行すると、共有リポジトリ越しに housings.all_occupants.size が1になること' do
    lion = run(:acquire_animal, commands::AcquireAnimalCommand.new(species_code: 'lion', name: 'レオ', sex: 'male')).value
    enclosure = container.enclosures.save(
      husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
    )

    run(:house_animal, commands::HouseAnimalCommand.new(enclosure_id: enclosure.id, animal_id: lion.id))

    expect(container.housings.all_occupants.size).to eq(1)
  end

  it 'conceive_animals(sire_id:, dam_id:) を実行すると、配線された dam が expecting? になること' do
    sire, dam = build_pair(catalog.lion)
    container.animals.save(sire)
    container.animals.save(dam)

    run(:conceive_animals, commands::ConceiveAnimalsCommand.new(sire_id: sire.id, dam_id: dam.id))

    expect(container.animals.find(dam.id)).to be_expecting
  end

  it 'deliver_animal(dam_id:, enclosure_id:) を実行すると births に1件記録され、子が animals に保存されること' do
    sire, dam = build_pair(catalog.lion)
    container.animals.save(sire)
    container.animals.save(dam)
    run(:conceive_animals, commands::ConceiveAnimalsCommand.new(sire_id: sire.id, dam_id: dam.id))
    catalog.lion.gestation_period_days.times { dam.gestate }
    container.animals.save(dam)
    enclosure = container.enclosures.save(
      husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
    )

    child = run(:deliver_animal, commands::DeliverAnimalCommand.new(dam_id: dam.id, enclosure_id: enclosure.id)).value

    expect(container.births.all.size).to eq(1)
    expect(container.animals.find(child.id)).to eq(child)
  end

  it "失敗した use case(species_code: 'dragon')は failure の Result を返すこと" do
    result = run(:acquire_animal, commands::AcquireAnimalCommand.new(species_code: 'dragon', name: 'X', sex: 'male'))

    expect(result).to be_failure
    expect(result.error).to be_a(Zoo::Application::Errors::SpeciesNotFound)
  end
end
