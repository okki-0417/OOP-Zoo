# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::Population do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:zebras) { build_pair(catalog.grevys_zebra) }
  let(:giraffe) { build_adult(catalog.reticulated_giraffe, name: 'キリン') }
  let(:macaques) { build_pair(catalog.japanese_macaque) }

  let(:savanna) do
    husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(30), capacity: 6)
  end
  let(:monkey_mountain) do
    husbandry::Enclosure.new(name: 'モンキーマウンテン', temperature: shared::Temperature.celsius(20), capacity: 8)
  end

  let(:housings) do
    events = zebras.map { |z| housed(z, savanna) }
    events << housed(giraffe, savanna)
    events.concat(macaques.map { |m| housed(m, monkey_mountain) })
    in_memory::InMemoryHousingRepository.new(events)
  end
  let(:query) { described_class.new(housings: housings) }

  describe '#call' do
    it '全エリアの occupants 合計を返すこと(サバンナ3頭+モンキーマウンテン2頭=5)' do
      expect(query.call).to eq(5)
    end
  end
end
