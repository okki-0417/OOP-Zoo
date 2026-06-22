# frozen_string_literal: true

RSpec.shared_examples 'an enclosure assignment repository' do
  def keeper(name = '田中', specialties: [Zoo::Domain::TaxonClass.mammal])
    keeper = Zoo::Domain::Keeper.new(name: name, specialties: specialties)
    persist_keepers(keeper)
    keeper
  end

  def pen(name = '区画')
    enclosure = Zoo::Domain::Enclosure.new(
      name: name, temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
    )
    persist_enclosures(enclosure)
    enclosure
  end

  it 'save した担当割り当てを all で復元できること' do
    tanaka = keeper
    savanna = pen('サバンナ')

    repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: savanna, occurred_on: 2))

    record = repository.all.first
    expect(record).to be_a(Zoo::Domain::EnclosureAssignment)
    expect(record.keeper_id).to eq(tanaka.id)
    expect(record.enclosure_id).to eq(savanna.id)
    expect(record.occurred_on).to eq(2)
  end

  it '割り当てが無ければ all は空であること' do
    expect(repository.all).to be_empty
  end

  describe '#enclosures_of' do
    it '飼育員が担当する全エリアを返すこと' do
      tanaka = keeper
      a = pen('A')
      b = pen('B')
      repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: a))
      repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: b))

      expect(repository.enclosures_of(tanaka)).to contain_exactly(a, b)
    end

    it '同じエリアへの重複割り当ては一度だけ返すこと' do
      tanaka = keeper
      a = pen('A')
      repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: a))
      repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: a))

      expect(repository.enclosures_of(tanaka)).to contain_exactly(a)
    end

    it '他の飼育員の割り当ては含まないこと' do
      tanaka = keeper('田中')
      suzuki = keeper('鈴木')
      a = pen('A')
      b = pen('B')
      repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: a))
      repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: suzuki, enclosure: b))

      expect(repository.enclosures_of(tanaka)).to contain_exactly(a)
    end

    it '退任したエリアは現在の担当から外れること' do
      tanaka = keeper
      a = pen('A')
      b = pen('B')
      repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: a))
      assignment_b = repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: b))
      repository.save(Zoo::Domain::EnclosureDischarge.of(assignment_b))

      expect(repository.enclosures_of(tanaka)).to contain_exactly(a)
    end

    it '退任後に再就任すると再び現在の担当に含まれること' do
      tanaka = keeper
      a = pen('A')
      first = repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: a))
      repository.save(Zoo::Domain::EnclosureDischarge.of(first))
      repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: a))

      expect(repository.enclosures_of(tanaka)).to contain_exactly(a)
    end
  end

  describe '#assignment_of' do
    it '現在の就任イベントを返すこと' do
      tanaka = keeper
      a = pen('A')
      assignment = repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: a))

      expect(repository.assignment_of(tanaka, a).id).to eq(assignment.id)
    end

    it '担当していないエリアには nil を返すこと' do
      tanaka = keeper
      a = pen('A')

      expect(repository.assignment_of(tanaka, a)).to be_nil
    end

    it '退任済みのエリアには nil を返すこと' do
      tanaka = keeper
      a = pen('A')
      assignment = repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: a))
      repository.save(Zoo::Domain::EnclosureDischarge.of(assignment))

      expect(repository.assignment_of(tanaka, a)).to be_nil
    end
  end

  describe '#all' do
    it '退任イベントも含めて記録順に復元すること' do
      tanaka = keeper
      a = pen('A')
      assignment = repository.save(Zoo::Domain::EnclosureAssignment.new(keeper: tanaka, enclosure: a))
      repository.save(Zoo::Domain::EnclosureDischarge.of(assignment))

      events = repository.all
      expect(events.map(&:class)).to eq([Zoo::Domain::EnclosureAssignment, Zoo::Domain::EnclosureDischarge])
      expect(events.last.assignment.id).to eq(assignment.id)
    end
  end
end
