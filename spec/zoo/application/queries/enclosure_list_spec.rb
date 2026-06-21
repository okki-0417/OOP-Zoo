# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::EnclosureList do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:housings) do
    in_memory::InMemoryHousingRepository.new([housed(build_adult(catalog.lion, name: 'レオ'), enclosure)])
  end

  describe '#call' do
    it 'エリアごとに id・名前・収容数・定員の読み取りモデルを返すこと' do
      row = described_class.new(enclosures: enclosures, housings: housings).call.first

      expect(row.id).to eq(enclosure.id.to_s)
      expect(row.name).to eq('ライオンの丘')
      expect(row.population).to eq(1)
      expect(row.capacity).to eq(4)
    end

    it '清掃直後のエリアは cleanliness=100・filthy=false を返すこと' do
      row = described_class.new(enclosures: enclosures, housings: housings).call.first

      expect(row.cleanliness).to eq(100)
      expect(row.filthy).to be(false)
    end

    it '集約ではなく ReadModels::EnclosureSummary を返すこと' do
      result = described_class.new(enclosures: enclosures, housings: housings).call

      expect(result).to all(be_a(Zoo::Application::ReadModels::EnclosureSummary))
    end
  end
end
