# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::EnclosureDetail do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
                        .tap { |e| e.admit(lion) }
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:query) { described_class.new(enclosures: enclosures) }

  describe '#call' do
    it '定員・収容数・清潔度・収容個体を含む詳細を返すこと' do
      profile = query.call(enclosure.id)

      expect(profile.name).to eq('ライオンの丘')
      expect(profile.capacity).to eq(4)
      expect(profile.population).to eq(1)
      expect(profile.cleanliness).to eq(100)
      expect(profile.occupants.map(&:name)).to eq(['レオ'])
    end

    it '存在しない id では nil を返すこと' do
      expect(query.call('missing')).to be_nil
    end
  end
end
