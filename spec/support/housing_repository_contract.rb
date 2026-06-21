# frozen_string_literal: true

RSpec.shared_examples 'a housing repository' do
  catalog = Zoo::Domain::SpeciesCatalog

  def pen(name = '区画')
    enclosure = Zoo::Domain::Enclosure.new(
      name: name, temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
    )
    persist_enclosures(enclosure)
    enclosure
  end

  it 'save した収容イベントを all で取り出せること' do
    animal = build_adult(catalog.lion, name: 'レオ')
    enclosure = pen
    persist_animals(animal)

    repository.save(Zoo::Domain::Housing.new(animal: animal, enclosure: enclosure, occurred_on: 3))

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

    repository.save(Zoo::Domain::Housing.new(animal: animal, enclosure: a))
    repository.save(Zoo::Domain::Housing.new(animal: animal, enclosure: b))

    occupancy = Zoo::Domain::Occupancy.new(repository.all)
    expect(occupancy.occupants_of(a)).to be_empty
    expect(occupancy.occupants_of(b)).to contain_exactly(animal)
  end

  it '解放イベントも保持し、解放後はどの区画にも属さないこと' do
    animal = build_adult(catalog.lion, name: 'レオ')
    enclosure = pen
    persist_animals(animal)

    housing = Zoo::Domain::Housing.new(animal: animal, enclosure: enclosure)
    repository.save(housing)
    repository.save(Zoo::Domain::Release.of(housing))

    last = repository.all.last
    expect(last).to be_a(Zoo::Domain::Release)
    expect(last.housing.id).to eq(housing.id)
    expect(Zoo::Domain::Occupancy.new(repository.all).enclosure_id_of(animal)).to be_nil
  end

  describe '#current_housing_of' do
    it '収容中はその入居イベントを返すこと' do
      animal = build_adult(catalog.lion, name: 'レオ')
      persist_animals(animal)
      housing = Zoo::Domain::Housing.new(animal: animal, enclosure: pen)
      repository.save(housing)

      expect(repository.current_housing_of(animal).id).to eq(housing.id)
    end

    it '解放済みなら nil を返すこと' do
      animal = build_adult(catalog.lion, name: 'レオ')
      persist_animals(animal)
      housing = Zoo::Domain::Housing.new(animal: animal, enclosure: pen)
      repository.save(housing)
      repository.save(Zoo::Domain::Release.of(housing))

      expect(repository.current_housing_of(animal)).to be_nil
    end

    it '転居後は移送先への入居イベントを返すこと' do
      animal = build_adult(catalog.lion, name: 'レオ')
      a = pen('A')
      b = pen('B')
      persist_animals(animal)
      first = Zoo::Domain::Housing.new(animal: animal, enclosure: a)
      repository.save(first)
      repository.save(Zoo::Domain::Release.of(first))
      second = Zoo::Domain::Housing.new(animal: animal, enclosure: b)
      repository.save(second)

      current = repository.current_housing_of(animal)
      expect(current.id).to eq(second.id)
      expect(current.enclosure_id).to eq(b.id)
    end
  end

  describe '#events_for_enclosure' do
    it 'その区画の占有を畳み込むと収容中の個体になること' do
      resident = build_adult(catalog.lion, name: '在住')
      a = pen('A')
      persist_animals(resident)
      repository.save(Zoo::Domain::Housing.new(animal: resident, enclosure: a))

      scoped = Zoo::Domain::Occupancy.new(repository.events_for_enclosure(a.id))
      expect(scoped.occupants_of(a)).to contain_exactly(resident)
    end

    it '転居で出ていった個体はその区画のスコープから外れること' do
      mover = build_adult(catalog.lion, name: '転居')
      a = pen('A')
      b = pen('B')
      persist_animals(mover)
      first = Zoo::Domain::Housing.new(animal: mover, enclosure: a)
      repository.save(first)
      repository.save(Zoo::Domain::Release.of(first))
      repository.save(Zoo::Domain::Housing.new(animal: mover, enclosure: b))

      scoped = Zoo::Domain::Occupancy.new(repository.events_for_enclosure(a.id))
      expect(scoped.occupants_of(a)).to be_empty
    end
  end
end
