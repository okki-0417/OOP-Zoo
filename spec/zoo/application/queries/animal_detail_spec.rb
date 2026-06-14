# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::AnimalDetail do
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:query) { described_class.new(animals: animals) }

  describe '#call' do
    it '個体 id を渡すと種・分類・性別・体力などを含む詳細を返すこと' do
      profile = query.call(lion.id)

      expect(profile.name).to eq('レオ')
      expect(profile.species).to eq('ライオン')
      expect(profile.taxon_class).to eq('哺乳類')
      expect(profile.sex).to eq('オス')
      expect(profile.life_stage).to eq('成体')
      expect(profile.max_health).to eq(100)
      expect(profile.alive).to be(true)
    end

    it '存在しない id を渡すと nil を返すこと' do
      expect(query.call('missing')).to be_nil
    end
  end
end
