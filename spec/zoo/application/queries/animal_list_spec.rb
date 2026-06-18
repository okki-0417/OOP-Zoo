# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::AnimalList do
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }

  describe '#call' do
    it '個体ごとに id・名前・種名・生存フラグの読み取りモデルを返すこと' do
      row = described_class.new(animals: animals).call.first

      expect(row.id).to eq(lion.id.to_s)
      expect(row.name).to eq('レオ')
      expect(row.species).to eq('ライオン')
      expect(row.alive).to be(true)
    end

    it '満タンで健康な個体は health=max_health・ailing=false を返すこと' do
      row = described_class.new(animals: animals).call.first

      expect(row.health).to eq(100)
      expect(row.max_health).to eq(100)
      expect(row.ailing).to be(false)
    end

    it '集約ではなく ReadModels::AnimalSummary を返すこと' do
      result = described_class.new(animals: animals).call

      expect(result).to all(be_a(Zoo::Application::ReadModels::AnimalSummary))
    end
  end
end
