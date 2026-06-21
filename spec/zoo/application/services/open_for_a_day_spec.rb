# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::OpenForADay do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  events    = Zoo::Domain::Events
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:survivor) { build_adult(catalog.lion, name: '若') }
  let(:elder) { build_animal(catalog.lion, name: '老', age_in_days: 1_000_000) }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([survivor, elder]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new([housed(survivor, enclosure), housed(elder, enclosure)]) }
  let(:event_store) { in_memory::InMemoryEventStore.new }
  let(:memorial_log) { Zoo::Infrastructure::Subscribers::MemorialLog.new }
  let(:event_dispatcher) do
    Zoo::Application::EventDispatcher.new(event_store: event_store, subscribers: [memorial_log])
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures, animals, housings]) }
  let(:service) do
    described_class.new(enclosures: enclosures, animals: animals, housings: housings,
                        event_dispatcher: event_dispatcher, unit_of_work: unit_of_work)
  end

  describe '#call' do
    it '生存個体が1日歳をとること' do
      expect { service.call }.to change { survivor.age_in_days }.by(1)
    end

    it 'エリアが頭数ぶん汚れて cleanliness.level が100未満になること' do
      service.call

      expect(enclosures.find(enclosure.id).cleanliness.level).to be < 100
    end

    it '寿命を超えた個体は死亡してエリアの occupants から外れ、戻り値に含まれること' do
      dead = service.call

      expect(dead).to include(elder)
      expect(occupants_of(housings, enclosure)).not_to include(elder)
    end

    it '死亡個体の AnimalDied が EventStore に追加されること' do
      service.call

      died = event_store.all.grep(events::AnimalDied)
      expect(died.map(&:animal)).to include(elder)
    end

    it '死亡が起きると購読者(MemorialLog)に慰霊記録が1件残ること' do
      service.call

      expect(memorial_log.entries.size).to eq(1)
    end

    it '誰も死なない開園では EventStore にイベントが残らないこと' do
      young_pen = husbandry::Enclosure.new(name: '若者エリア', temperature: shared::Temperature.celsius(28), capacity: 4)
      young_only = in_memory::InMemoryEnclosureRepository.new([young_pen])
      young_housings = in_memory::InMemoryHousingRepository.new([housed(survivor, young_pen)])
      described_class.new(enclosures: young_only, animals: animals, housings: young_housings,
                          event_dispatcher: event_dispatcher, unit_of_work: unit_of_work).call

      expect(event_store.all).to be_empty
    end
  end
end
