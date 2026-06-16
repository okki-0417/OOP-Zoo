# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::Sqlite::EnclosureRepository do
  shared = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  sqlite = Zoo::Infrastructure::Sqlite

  let(:database) { sqlite::Database.new }
  let(:animals) { sqlite::AnimalRepository.new(database) }
  let(:repository) { described_class.new(database, animals) }

  it_behaves_like 'an enclosure repository'

  it '収容個体(occupants)を id 参照で保存し、animals 経由で復元できること' do
    lion = build_adult(catalog.lion, name: 'レオ')
    animals.save(lion)
    enclosure = husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
    enclosure.admit(lion)

    repository.save(enclosure)
    restored = repository.find(enclosure.id)

    expect(restored.occupants.map { |a| a.name.to_s }).to eq(['レオ'])
    expect(restored.houses?(lion)).to be(true)
  end
end
