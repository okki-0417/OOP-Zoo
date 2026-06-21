# frozen_string_literal: true

RSpec.shared_examples 'a housing repository' do
  catalog = Zoo::Domain::SpeciesCatalog

  def pen(name = '区画')
    Zoo::Domain::Enclosure.new(
      name: name, temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
    )
  end

  it 'save した収容イベントを all で取り出せること' do
    animal = build_adult(catalog.lion, name: 'レオ')
    enclosure = pen
    persist_animals(animal)

    repository.save(Zoo::Domain::Housing.record(animal: animal, enclosure: enclosure, occurred_on: 3))

    record = repository.all.first
    expect(record).to be_a(Zoo::Domain::Housing)
    expect(record.animal).to eq(animal)
    expect(record.enclosure_id).to eq(enclosure.id)
    expect(record.occurred_on).to eq(3)
  end

  it 'イベントが無ければ all は空であること' do
    expect(repository.all).to be_empty
  end

  it '記録した順序を保ち、最後の収容イベントが現在の収容になること' do
    animal = build_adult(catalog.lion, name: 'レオ')
    a = pen('A')
    b = pen('B')
    persist_animals(animal)

    repository.save(Zoo::Domain::Housing.record(animal: animal, enclosure: a))
    repository.save(Zoo::Domain::Housing.record(animal: animal, enclosure: b))

    occupancy = Zoo::Domain::Occupancy.new(repository.all)
    expect(occupancy.occupants_of(a)).to be_empty
    expect(occupancy.occupants_of(b)).to contain_exactly(animal)
  end

  it '解放イベントも保持し、解放後はどの区画にも属さないこと' do
    animal = build_adult(catalog.lion, name: 'レオ')
    enclosure = pen
    persist_animals(animal)

    housing = Zoo::Domain::Housing.record(animal: animal, enclosure: enclosure)
    repository.save(housing)
    repository.save(Zoo::Domain::Release.of(housing))

    last = repository.all.last
    expect(last).to be_a(Zoo::Domain::Release)
    expect(last.housing.id).to eq(housing.id)
    expect(Zoo::Domain::Occupancy.new(repository.all).enclosure_id_of(animal)).to be_nil
  end
end
