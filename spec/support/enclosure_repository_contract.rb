# frozen_string_literal: true

RSpec.shared_examples 'an enclosure repository' do
  def sample_enclosure(name = '丘')
    Zoo::Domain::Enclosure.new(
      name: name, temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
    )
  end

  it 'save した区画を find で取り出せること(名前・定員・清潔度)' do
    enclosure = sample_enclosure
    enclosure.soil(30)

    repository.save(enclosure)
    found = repository.find(enclosure.id)

    expect(found.name).to eq('丘')
    expect(found.capacity).to eq(4)
    expect(found.cleanliness.level).to eq(70)
  end

  it '存在しない id は nil を返すこと' do
    expect(repository.find('missing')).to be_nil
  end

  it 'all で保存した全区画を返すこと' do
    repository.save(sample_enclosure('A'))
    repository.save(sample_enclosure('B'))

    expect(repository.all.size).to eq(2)
  end

  it '刺激度と空調の有無を保存して復元できること' do
    enclosure = Zoo::Domain::Enclosure.new(
      name: '温室', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4,
      climate_controlled: true
    )
    enclosure.deplete_enrichment(40)

    repository.save(enclosure)
    found = repository.find(enclosure.id)

    expect(found.enrichment.level).to eq(60)
    expect(found).to be_climate_controlled
  end
end
