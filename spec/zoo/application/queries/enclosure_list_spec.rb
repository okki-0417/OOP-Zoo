# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::EnclosureList do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
                        .tap { |e| e.admit(build_adult(catalog.lion, name: 'レオ')) }
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }

  describe '#call' do
    it 'エリアごとに id・名前・収容数・定員の読み取りモデルを返すこと' do
      row = described_class.new(enclosures: enclosures).call.first

      expect(row.id).to eq(enclosure.id.to_s)
      expect(row.name).to eq('ライオンの丘')
      expect(row.population).to eq(1)
      expect(row.capacity).to eq(4)
    end

    it '集約ではなく ReadModels::EnclosureSummary を返すこと' do
      result = described_class.new(enclosures: enclosures).call

      expect(result).to all(be_a(Zoo::Application::ReadModels::EnclosureSummary))
    end
  end
end
