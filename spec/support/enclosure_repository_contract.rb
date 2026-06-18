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
end
