# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::ThreatenedSpecies do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:zebras) { build_pair(catalog.grevys_zebra) }
  let(:giraffe) { build_adult(catalog.reticulated_giraffe, name: 'キリン') }
  let(:macaques) { build_pair(catalog.japanese_macaque) }

  let(:savanna) do
    husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(30), capacity: 6)
                        .tap do |e|
      zebras.each { |z| e.admit(z) }
      e.admit(giraffe)
    end
  end
  let(:monkey_mountain) do
    husbandry::Enclosure.new(name: 'モンキーマウンテン', temperature: shared::Temperature.celsius(20), capacity: 8)
                        .tap { |e| macaques.each { |m| e.admit(m) } }
  end

  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([savanna, monkey_mountain]) }
  let(:query) { described_class.new(enclosures: enclosures) }

  describe '#call' do
    it '展示中の絶滅危惧種だけを種ごとに集計し、LC のニホンザルは含めないこと' do
      names = query.call.map(&:name_ja)

      expect(names).to contain_exactly('グレビーシマウマ', 'アミメキリン')
    end

    it 'グレビーシマウマ2頭を展示すると count=2・status_code=\'EN\' の読み取りモデルを返すこと' do
      zebra = query.call.find { |read_model| read_model.name_ja == 'グレビーシマウマ' }

      expect(zebra.count).to eq(2)
      expect(zebra.status_code).to eq('EN')
    end

    it '集約ではなく読み取りモデル(ReadModels::ExhibitedSpecies)を返すこと' do
      expect(query.call).to all(be_a(Zoo::Application::ReadModels::ExhibitedSpecies))
    end
  end
end
