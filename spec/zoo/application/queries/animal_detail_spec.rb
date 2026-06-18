# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::AnimalDetail do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new }
  let(:query) { described_class.new(animals: animals, enclosures: enclosures) }

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

    it 'どのエリアにも収容されていないと enclosure_id/enclosure_name が nil であること' do
      profile = query.call(lion.id)

      expect(profile.enclosure_id).to be_nil
      expect(profile.enclosure_name).to be_nil
    end

    it '収容中のエリアがあると enclosure_id/enclosure_name にそのエリアを返すこと' do
      enclosure = husbandry::Enclosure.new(
        name: 'サバンナ', temperature: shared::Temperature.celsius(28), capacity: 4
      )
      enclosure.admit(lion)
      enclosures.save(enclosure)

      profile = query.call(lion.id)

      expect(profile.enclosure_id).to eq(enclosure.id.to_s)
      expect(profile.enclosure_name).to eq('サバンナ')
    end

    it '存在しない id を渡すと nil を返すこと' do
      expect(query.call('missing')).to be_nil
    end
  end
end
