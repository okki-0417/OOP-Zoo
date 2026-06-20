# frozen_string_literal: true

RSpec.shared_examples 'a birth repository' do
  catalog = Zoo::Domain::SpeciesCatalog

  def build_birth(sire, dam, offspring, day: 0, season: Zoo::Domain::Season.spring)
    Zoo::Domain::Birth.reconstitute(
      id: Zoo::Domain::Shared::Identifier.new, sire: sire, dam: dam,
      offspring: offspring, day: day, season: season
    )
  end

  it 'save した出産イベントを all で取り出し、親子を辿れること' do
    sire, dam = build_pair(catalog.lion)
    offspring = build_adult(catalog.lion, name: '仔')
    persist_animals(sire, dam, offspring)

    repository.save(build_birth(sire, dam, offspring, day: 120, season: Zoo::Domain::Season.autumn))

    record = repository.all.first
    expect(record.sire).to eq(sire)
    expect(record.dam).to eq(dam)
    expect(record.offspring).to eq(offspring)
    expect(record.day).to eq(120)
    expect(record.season).to eq(Zoo::Domain::Season.autumn)
  end

  it '出産が無ければ all は空であること' do
    expect(repository.all).to be_empty
  end

  it '複数の出産をすべて保持すること' do
    sire, dam = build_pair(catalog.lion)
    a = build_adult(catalog.lion, name: 'A')
    b = build_adult(catalog.lion, name: 'B')
    persist_animals(sire, dam, a, b)

    repository.save(build_birth(sire, dam, a))
    repository.save(build_birth(sire, dam, b))

    expect(repository.all.size).to eq(2)
  end
end
