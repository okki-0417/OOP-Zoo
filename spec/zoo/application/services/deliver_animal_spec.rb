# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::DeliverAnimal do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  events    = Zoo::Domain::Events
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:pair) { build_pair(catalog.lion) }
  let(:sire) { pair[0] }
  let(:dam)  { pair[1] }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:animals) { in_memory::InMemoryAnimalRepository.new([sire, dam]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:keepers) { in_memory::InMemoryKeeperRepository.new }
  let(:event_store) { in_memory::InMemoryEventStore.new }
  let(:birth_announcements) { Zoo::Infrastructure::Subscribers::BirthAnnouncementLog.new }
  let(:event_dispatcher) do
    Zoo::Application::EventDispatcher.new(event_store: event_store, subscribers: [birth_announcements])
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals, enclosures]) }
  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: '園', admission_fee: shared::Money.yen(2000))
    )
  end
  let(:service) do
    described_class.new(animals: animals, enclosures: enclosures, keepers: keepers, zoo: zoo,
                        event_dispatcher: event_dispatcher, unit_of_work: unit_of_work)
  end

  def command(dam_id: dam.id, enclosure_id: enclosure.id, keeper_id: nil)
    Zoo::Application::Commands::DeliverAnimalCommand.new(
      dam_id: dam_id, enclosure_id: enclosure_id, keeper_id: keeper_id
    )
  end

  def prepare_dam_for_delivery
    dam.conceive(sire_id: sire.id)
    Zoo::Domain::SpeciesCatalog.lion.gestation_period_days.times { dam.gestate }
    animals.save(dam)
  end

  describe '#call' do
    before { prepare_dam_for_delivery }

    it 'dam_id/enclosure_id を渡すと、生まれた子が両親を parent_ids に持ちエリアに収容されること' do
      child = service.call(command)

      expect(child.parent_ids).to contain_exactly(sire.id, dam.id)
      expect(enclosures.find(enclosure.id).occupants).to include(child)
      expect(animals.find(child.id)).to eq(child)
    end

    it '出産に成功すると Birth が births に1件永続化されること' do
      service.call(command)

      expect(animals.births.size).to eq(1)
      expect(animals.births.first).to be_a(events::Birth)
    end

    it '出産イベントは EventStore には永続化されないこと(births テーブルが台帳)' do
      service.call(command)

      expect(event_store.all).to be_empty
    end

    it '出産に成功すると購読者(BirthAnnouncementLog)に誕生が1件通知されること' do
      service.call(command)

      expect(birth_announcements.announcements.size).to eq(1)
    end

    it '定員1の満員エリアに収容できず CapacityExceeded になると、子が保存されずロールバックされること' do
      resident = build_adult(catalog.lion, name: '先住')
      full = husbandry::Enclosure.new(name: '小屋', temperature: shared::Temperature.celsius(28), capacity: 1)
                                 .tap { |e| e.admit(resident) }
      enclosures.save(full)

      expect { service.call(command(enclosure_id: full.id)) }
        .to raise_error(Zoo::Domain::Errors::CapacityExceeded)
      expect(animals.all.size).to eq(2)
    end

    it 'ロールバックされた出産の記録は births に残らないこと' do
      resident = build_adult(catalog.lion, name: '先住')
      full = husbandry::Enclosure.new(name: '小屋', temperature: shared::Temperature.celsius(28), capacity: 1)
                                 .tap { |e| e.admit(resident) }
      enclosures.save(full)

      expect { service.call(command(enclosure_id: full.id)) }.to raise_error(Zoo::Domain::Errors::CapacityExceeded)
      expect(animals.births).to be_empty
    end

    it '存在しない dam_id を渡すと AnimalNotFound が発生すること' do
      expect { service.call(command(dam_id: 'missing')) }
        .to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end

    it '存在しない enclosure_id を渡すと EnclosureNotFound が発生すること' do
      expect { service.call(command(enclosure_id: 'missing')) }
        .to raise_error(Zoo::Application::Errors::EnclosureNotFound)
    end

    it '存在しない keeper_id を渡すと KeeperNotFound が発生すること' do
      expect { service.call(command(keeper_id: 'missing')) }
        .to raise_error(Zoo::Application::Errors::KeeperNotFound)
    end
  end

  describe '出産準備前の dam' do
    it 'ready_to_deliver でない dam に対して BreedingNotAllowed が伝播すること' do
      expect { service.call(command) }
        .to raise_error(Zoo::Domain::Errors::BreedingNotAllowed)
    end
  end
end
