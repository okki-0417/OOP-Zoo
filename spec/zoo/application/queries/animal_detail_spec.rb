# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::AnimalDetail do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory
  commands  = Zoo::Application::Commands

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new }
  let(:housings) { in_memory::InMemoryHousingRepository.new }
  let(:query) do
    lambda do |animal_id|
      command = commands::AnimalDetailCommand.new(animal_id: animal_id).bind(animals: animals, housings: housings)
      described_class.new(command: command).call
    end
  end

  describe '#call' do
    it '個体 id を渡すと種・分類・性別・体力などを含む詳細を返すこと' do
      profile = query.call(lion.id).value

      expect(profile.name).to eq('レオ')
      expect(profile.species).to eq('ライオン')
      expect(profile.taxon_class).to eq('哺乳類')
      expect(profile.sex).to eq('オス')
      expect(profile.life_stage).to eq('成体')
      expect(profile.max_health).to eq(100)
      expect(profile.alive).to be(true)
    end

    it 'どのエリアにも収容されていないと enclosure_id/enclosure_name が nil であること' do
      profile = query.call(lion.id).value

      expect(profile.enclosure_id).to be_nil
      expect(profile.enclosure_name).to be_nil
    end

    it '収容中のエリアがあると enclosure_id/enclosure_name にそのエリアを返すこと' do
      enclosure = husbandry::Enclosure.new(
        name: 'サバンナ', temperature: shared::Temperature.celsius(28), capacity: 4
      )
      enclosures.save(enclosure)
      housings.save(housed(lion, enclosure))

      profile = query.call(lion.id).value

      expect(profile.enclosure_id).to eq(enclosure.id.to_s)
      expect(profile.enclosure_name).to eq('サバンナ')
    end

    it "存在しない id 'missing' を渡すと AnimalNotFound の失敗 Result を返すこと" do
      result = query.call('missing')

      expect(result).to be_failure
      expect(result.error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
