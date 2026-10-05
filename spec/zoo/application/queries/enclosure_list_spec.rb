# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::EnclosureList do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory
  commands  = Zoo::Application::Commands

  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:housings) do
    in_memory::InMemoryHousingRepository.new([housed(build_adult(catalog.lion, name: 'レオ'), enclosure)])
  end

  let(:query) do
    described_class.new(command: commands::EnclosureListCommand.new.bind(
      enclosures:, housings:, assignments: Factory::AssignmentRepository.build
    ))
  end

  describe '#call' do
    it 'エリアごとに id・名前・収容数・定員の読み取りモデルを返すこと' do
      row = query.call.value.first

      expect(row.id).to eq(enclosure.id.to_s)
      expect(row.name).to eq('ライオンの丘')
      expect(row.population).to eq(1)
      expect(row.capacity).to eq(4)
    end

    it '清掃直後のエリアは cleanliness=100・filthy=false を返すこと' do
      row = query.call.value.first

      expect(row.cleanliness).to eq(100)
      expect(row.filthy).to be(false)
    end

    it '設定温度28℃・空調なしのエリアは celsius=28.0・climate_controlled=false を返すこと' do
      expect(query.call.value.first).to have_attributes(celsius: 28.0, climate_controlled: false)
    end

    it '住んでいるレオを occupants に AnimalSummary として返すこと' do
      expect(query.call.value.first.occupants.map(&:name)).to eq(['レオ'])
    end

    it '集約ではなく ReadModels::EnclosureProfile を返すこと' do
      rows = query.call.value

      expect(rows).to all(be_a(Zoo::Application::ReadModels::EnclosureProfile))
    end
  end
end
