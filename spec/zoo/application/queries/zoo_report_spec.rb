# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::ZooReport do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  events    = Zoo::Domain::Events
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:zebra) { build_adult(catalog.grevys_zebra, name: 'シマオ') }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(30), capacity: 6)
                        .tap { |e| e.admit(zebra) }
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:event_store) { in_memory::InMemoryEventStore.new }
  let(:animals) { in_memory::InMemoryAnimalRepository.new }
  let(:zoo) do
    in_memory::InMemoryZooRepository.new(Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2000)))
  end

  let(:query) { described_class.new(enclosures: enclosures, event_store: event_store, zoo: zoo, animals: animals) }

  describe '#call' do
    it '在園・種数・絶滅危惧種数を集計すること' do
      stats = query.call

      expect(stats.population).to eq(1)
      expect(stats.species_count).to eq(1)
      expect(stats.threatened_count).to eq(1)
    end

    it '出生数は AnimalRepository の births から、死因別死亡数は EventStore から集計すること' do
      newborn = build_adult(catalog.grevys_zebra, name: '仔')
      newborn.record_event(events::Birth.new(offspring: newborn, sire_id: 's', dam_id: 'd',
                                             occurred_on: 0, season: Zoo::Domain::Season.spring))
      animals.save(newborn)
      event_store.append(events::AnimalDied.new(animal: zebra, cause: :old_age))
      event_store.append(events::AnimalDied.new(animal: zebra, cause: :starvation))

      stats = query.call

      expect(stats.births).to eq(1)
      expect(stats.deaths_by_cause).to eq(old_age: 1, starvation: 1)
    end
  end
end
