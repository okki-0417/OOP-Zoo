# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::ThreatenedSpecies do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory
  commands  = Zoo::Application::Commands

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
  let(:service) { described_class.new(command: commands::ThreatenedSpeciesCommand.new.bind(housings: housings)) }

  describe '#call' do
    it '展示中の絶滅危惧種だけを種ごとに集計し、LC のニホンザルは含めないこと' do
      names = service.call.value.map { |view| view[:species].name_ja }

      expect(names).to contain_exactly('グレビーシマウマ', 'アミメキリン')
    end

    it 'グレビーシマウマ2頭を展示すると count=2 を返すこと' do
      zebra = service.call.value.find { |view| view[:species].name_ja == 'グレビーシマウマ' }

      expect(zebra[:count]).to eq(2)
    end
  end
end
