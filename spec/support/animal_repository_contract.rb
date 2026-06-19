# frozen_string_literal: true

RSpec.shared_examples 'an animal repository' do
  catalog = Zoo::Domain::SpeciesCatalog
  medical = Zoo::Domain

  it 'save した個体を find で取り出せること' do
    lion = build_adult(catalog.lion, name: 'レオ')

    repository.save(lion)
    found = repository.find(lion.id)

    expect(found.name.to_s).to eq('レオ')
    expect(found.species).to eq(catalog.lion)
  end

  it '存在しない id は nil を返すこと' do
    expect(repository.find('missing')).to be_nil
  end

  it 'all で保存した全個体を返すこと' do
    repository.save(build_adult(catalog.lion, name: 'A'))
    repository.save(build_adult(catalog.lion, name: 'B'))

    expect(repository.all.size).to eq(2)
  end

  it '空腹・ストレス・病気・免疫などの内部状態を保存して復元できること' do
    lion = build_adult(catalog.lion, name: 'レオ')
    lion.get_hungrier(40)
    lion.add_stress(50)
    lion.fall_ill(medical::IllnessCatalog.cold)
    lion.recover
    lion.fall_ill(medical::IllnessCatalog.pneumonia)

    repository.save(lion)
    found = repository.find(lion.id)

    expect(found.hunger.level).to eq(40)
    expect(found.stress.level).to eq(50)
    expect(found).to be_sick
    expect(found.immune_to?(medical::IllnessCatalog.cold)).to be(true)
  end

  it 'save 時に集約が記録した Birth を births として永続化し、往復できること' do
    dam = build_adult(catalog.lion, name: '母', sex: Zoo::Domain::Animal::Sex.female)
    offspring = build_adult(catalog.lion, name: '仔')
    repository.save(offspring)
    dam.record_event(Zoo::Domain::Events::Birth.new(
                       offspring: offspring, sire_id: Zoo::Domain::Shared::Identifier.new, dam_id: dam.id,
                       occurred_on: 120, season: Zoo::Domain::Season.autumn
                     ))
    repository.save(dam)

    births = repository.births
    expect(births.size).to eq(1)
    expect(births.first.offspring.name.to_s).to eq('仔')
    expect(births.first.occurred_on).to eq(120)
    expect(births.first.season).to eq(Zoo::Domain::Season.autumn)
  end
end
