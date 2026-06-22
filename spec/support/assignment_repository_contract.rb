# frozen_string_literal: true

RSpec.shared_examples 'an assignment repository' do
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

  def tend(keeper, enclosure, occurred_on: 0)
    repository.save(Zoo::Domain::Tending.new(keeper: keeper, enclosure: enclosure, occurred_on: occurred_on))
  end

  def relieve(keeper, enclosure)
    repository.save(Zoo::Domain::Relieving.of(repository.active_tending_of(keeper, enclosure)))
  end

  it 'save した就任を all で復元できること' do
    tanaka = keeper
    savanna = pen('サバンナ')

    tend(tanaka, savanna, occurred_on: 2)

    tending = repository.all.first
    expect(tending).to be_a(Zoo::Domain::Tending)
    expect(tending.keeper_id).to eq(tanaka.id)
    expect(tending.enclosure_id).to eq(savanna.id)
    expect(tending.occurred_on).to eq(2)
  end

  it '就任が無ければ all は空であること' do
    expect(repository.all).to be_empty
  end

  it '退任イベントも all に経歴として残ること' do
    tanaka = keeper
    a = pen('A')
    tend(tanaka, a)
    relieve(tanaka, a)

    expect(repository.all.map(&:class)).to eq([Zoo::Domain::Tending, Zoo::Domain::Relieving])
  end

  describe '#enclosures_of' do
    it '飼育員が現在担当する全エリアを返すこと' do
      tanaka = keeper
      a = pen('A')
      b = pen('B')
      tend(tanaka, a)
      tend(tanaka, b)

      expect(repository.enclosures_of(tanaka)).to contain_exactly(a, b)
    end

    it '他の飼育員の担当は含まないこと' do
      tanaka = keeper('田中')
      suzuki = keeper('鈴木')
      a = pen('A')
      b = pen('B')
      tend(tanaka, a)
      tend(suzuki, b)

      expect(repository.enclosures_of(tanaka)).to contain_exactly(a)
    end

    it '退任したエリアは現在の担当から外れること' do
      tanaka = keeper
      a = pen('A')
      b = pen('B')
      tend(tanaka, a)
      tend(tanaka, b)
      relieve(tanaka, b)

      expect(repository.enclosures_of(tanaka)).to contain_exactly(a)
    end
  end

  describe '#active_tending_of' do
    it '現役の就任イベントを返すこと' do
      tanaka = keeper
      a = pen('A')
      saved = tend(tanaka, a)

      expect(repository.active_tending_of(tanaka, a).id).to eq(saved.id)
    end

    it '担当していないエリアには nil を返すこと' do
      tanaka = keeper
      a = pen('A')

      expect(repository.active_tending_of(tanaka, a)).to be_nil
    end

    it '退任済みのエリアには nil を返すこと' do
      tanaka = keeper
      a = pen('A')
      tend(tanaka, a)
      relieve(tanaka, a)

      expect(repository.active_tending_of(tanaka, a)).to be_nil
    end
  end

  describe '#keepers_of' do
    it 'エリアを現在担当する全飼育員を返すこと' do
      tanaka = keeper('田中')
      suzuki = keeper('鈴木')
      a = pen('A')
      tend(tanaka, a)
      tend(suzuki, a)

      expect(repository.keepers_of(a)).to contain_exactly(tanaka, suzuki)
    end

    it '他のエリアの担当は含まないこと' do
      tanaka = keeper('田中')
      suzuki = keeper('鈴木')
      a = pen('A')
      b = pen('B')
      tend(tanaka, a)
      tend(suzuki, b)

      expect(repository.keepers_of(a)).to contain_exactly(tanaka)
    end

    it '退任した飼育員は現在の担当から外れること' do
      tanaka = keeper
      a = pen('A')
      tend(tanaka, a)
      relieve(tanaka, a)

      expect(repository.keepers_of(a)).to be_empty
    end
  end
end
