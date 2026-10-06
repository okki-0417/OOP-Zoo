# frozen_string_literal: true

RSpec.shared_examples 'an animal repository' do
  catalog = Zoo::Domain::SpeciesCatalog
  medical = Zoo::Domain

  it 'save した個体を find で取り出せること' do
    lion = build_adult(catalog.lion, name: 'レオ')

    repository.save(lion)
    found = repository.find(lion.id)

    expect(found.name).to eq('レオ')
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

    expect(found.hunger_level).to eq(40)
    expect(found.stress_level).to eq(50)
    expect(found).to be_sick
    expect(found.immune_to?(medical::IllnessCatalog.cold)).to be(true)
  end

  it '栄養状態・その日の食事・妊娠日数を保存して復元できること' do
    sire, dam = build_pair(catalog.lion)
    dam.conceive(inbreeding: 0.125)
    dam.gestate(30)
    dam.take_meal([:meat])
    dam.settle_nutrition
    dam.settle_nutrition
    dam.take_meal([:meat])

    repository.save(dam)
    found = repository.find(dam.id)

    expect(found.nutrition_level).to eq(75)
    expect(found.meals.categories).to eq([:meat])
    expect(found.gestation_days).to eq(30)
    expect(found.expected_offspring_inbreeding).to eq(0.125)
    expect(found.expected_offspring_sex).to eq(dam.expected_offspring_sex)
    expect(sire).not_to be_expecting
  end

  it '流産した事実を保存して復元できること' do
    _sire, dam = build_pair(catalog.lion)
    dam.conceive
    dam.get_hungrier(100)
    dam.gestate(1)

    repository.save(dam)
    found = repository.find(dam.id)

    expect(found).to be_miscarried
    expect(found).not_to be_expecting
  end
end
