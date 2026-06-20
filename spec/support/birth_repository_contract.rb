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

  describe '#ancestry' do
    it '対象個体の祖先を成す出産だけを世代を遡って返すこと' do
      grandsire, granddam = build_pair(catalog.lion)
      sire = build_adult(catalog.lion, name: '父')
      dam = build_adult(catalog.lion, name: '母')
      child = build_adult(catalog.lion, name: '子')
      outsider = build_adult(catalog.lion, name: '無関係')
      persist_animals(grandsire, granddam, sire, dam, child, outsider)

      repository.save(build_birth(grandsire, granddam, dam))
      repository.save(build_birth(sire, dam, child))
      repository.save(build_birth(grandsire, granddam, outsider))

      offspring_ids = repository.ancestry(child).map { |birth| birth.offspring.id }
      expect(offspring_ids).to contain_exactly(child.id, dam.id)
    end

    it '出産記録のない創始個体には空を返すこと' do
      founder = build_adult(catalog.lion, name: '創始')
      persist_animals(founder)

      expect(repository.ancestry(founder)).to be_empty
    end

    it '対象個体を渡さなければ空を返すこと' do
      expect(repository.ancestry).to be_empty
    end

    it 'max_depth を超える世代は辿らないこと' do
      grandsire, granddam = build_pair(catalog.lion)
      dam = build_adult(catalog.lion, name: '母')
      child = build_adult(catalog.lion, name: '子')
      persist_animals(grandsire, granddam, dam, child)

      repository.save(build_birth(grandsire, granddam, dam))
      repository.save(build_birth(grandsire, dam, child))

      offspring_ids = repository.ancestry(child, max_depth: 1).map { |birth| birth.offspring.id }
      expect(offspring_ids).to contain_exactly(child.id)
    end
  end
end
