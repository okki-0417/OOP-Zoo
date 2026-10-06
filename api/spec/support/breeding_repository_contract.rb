# frozen_string_literal: true

RSpec.shared_examples 'a breeding repository' do
  catalog  = Zoo::Domain::SpeciesCatalog
  breeding = Zoo::Domain::Breeding

  it 'save した受胎イベントを dam から辿れること' do
    sire, dam = build_pair(catalog.lion)
    persist_animals(sire, dam)

    repository.save(breeding.new(sire:, dam:, day: 30, season: Zoo::Domain::Season.summer))

    found = repository.for_dam(dam.id)
    expect(found.sire).to eq(sire)
    expect(found.dam).to eq(dam)
    expect(found.day).to eq(30)
    expect(found.season).to eq(Zoo::Domain::Season.summer)
  end

  it '受胎のない dam では for_dam が nil を返すこと' do
    expect(repository.for_dam('missing')).to be_nil
  end

  it '同じ dam が複数回受胎すると、最新の受胎を返すこと' do
    old_sire, dam = build_pair(catalog.lion)
    new_sire = build_adult(catalog.lion, name: '新しい父')
    persist_animals(old_sire, new_sire, dam)

    repository.save(breeding.new(sire: old_sire, dam:, day: 10))
    repository.save(breeding.new(sire: new_sire, dam:, day: 400))

    expect(repository.for_dam(dam.id).sire).to eq(new_sire)
  end
end
