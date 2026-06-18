# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::BreedAnimals do
  shared    = Zoo::Domain::Shared
  animal    = Zoo::Domain::Animal
  husbandry = Zoo::Domain
  events    = Zoo::Domain::Events
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:pair) { build_pair(catalog.lion) }
  let(:sire) { pair[0] }
  let(:dam) { pair[1] }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:animals) { in_memory::InMemoryAnimalRepository.new([sire, dam]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
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
    described_class.new(animals: animals, enclosures: enclosures, zoo: zoo,
                        event_dispatcher: event_dispatcher, unit_of_work: unit_of_work)
  end

  def command(sire_id: sire.id, dam_id: dam.id, enclosure_id: enclosure.id, name: 'シンバ',
              sex: Zoo::Domain::Animal::Sex.male)
    Zoo::Application::Commands::BreedAnimalsCommand.new(
      sire_id: sire_id, dam_id: dam_id, enclosure_id: enclosure_id, name: name, sex: sex
    )
  end

  describe '#call' do
    it 'sire/dam/エリアの id を渡すと、生まれた子が両親を parent_ids に持ちエリアに収容されること' do
      child = service.call(command)

      expect(child.parent_ids).to contain_exactly(sire.id, dam.id)
      expect(enclosures.find(enclosure.id).occupants).to include(child)
      expect(animals.find(child.id)).to eq(child)
    end

    it '出産に成功すると AnimalBorn が EventStore に1件追加されること' do
      service.call(command)

      expect(event_store.all.size).to eq(1)
      expect(event_store.all.first).to be_a(events::AnimalBorn)
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

    it 'ロールバックされた出産のイベントは EventStore に残らないこと' do
      resident = build_adult(catalog.lion, name: '先住')
      full = husbandry::Enclosure.new(name: '小屋', temperature: shared::Temperature.celsius(28), capacity: 1)
                                 .tap { |e| e.admit(resident) }
      enclosures.save(full)

      expect { service.call(command(enclosure_id: full.id)) }.to raise_error(Zoo::Domain::Errors::CapacityExceeded)
      expect(event_store.all).to be_empty
    end

    it 'オス同士を渡すと Domain::Errors::BreedingNotAllowed が伝播すること' do
      other_male = build_adult(catalog.lion, name: 'もう一頭', sex: animal::Sex.male)
      animals.save(other_male)

      expect { service.call(command(dam_id: other_male.id)) }
        .to raise_error(Zoo::Domain::Errors::BreedingNotAllowed)
    end

    it '存在しない sire_id=\'missing\' を渡すと Application::Errors::AnimalNotFound が発生すること' do
      expect { service.call(command(sire_id: 'missing')) }
        .to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end

    it '季節繁殖種(ニホンザル=秋)は繁殖季節でない季節には繁殖できないこと(BreedingNotAllowed)' do
      m_sire, m_dam = build_pair(catalog.japanese_macaque)
      m_enclosure = husbandry::Enclosure.new(
        name: 'モンキーマウンテン', temperature: shared::Temperature.celsius(20), capacity: 4
      )
      m_animals = in_memory::InMemoryAnimalRepository.new([m_sire, m_dam])
      m_enclosures = in_memory::InMemoryEnclosureRepository.new([m_enclosure])

      summer = Zoo::Domain::Zoo.new(name: '園', admission_fee: shared::Money.yen(2000))
      100.times { summer.advance_day }
      summer_service = described_class.new(
        animals: m_animals, enclosures: m_enclosures, zoo: in_memory::InMemoryZooRepository.new(summer),
        event_dispatcher: event_dispatcher,
        unit_of_work: in_memory::InMemoryUnitOfWork.new(repositories: [m_animals, m_enclosures])
      )
      m_command = Zoo::Application::Commands::BreedAnimalsCommand.new(
        sire_id: m_sire.id, dam_id: m_dam.id, enclosure_id: m_enclosure.id, name: '仔',
        sex: animal::Sex.male
      )

      expect { summer_service.call(m_command) }.to raise_error(Zoo::Domain::Errors::BreedingNotAllowed)
    end

    it '血統から近交係数を求め、血縁の近い親(祖父×孫娘)の子は近交弱勢で虚弱になること' do
      male = animal::Sex.male
      female = animal::Sex.female
      grandpa = animal.new(species: catalog.lion, name: '祖父', sex: male, max_health: 100, age_in_days: 4000)
      grandma = animal.new(species: catalog.lion, name: '祖母', sex: female, max_health: 100, age_in_days: 6000)
      mother = animal.new(species: catalog.lion, name: '母', sex: female, max_health: 100, age_in_days: 3000,
                          sire: grandpa, dam: grandma)
      outsider = animal.new(species: catalog.lion, name: '外', sex: male, max_health: 100, age_in_days: 6000)
      granddaughter = animal.new(species: catalog.lion, name: '孫娘', sex: female, max_health: 100, age_in_days: 1200,
                                 sire: outsider, dam: mother)
      [grandpa, grandma, mother, outsider, granddaughter].each { |a| animals.save(a) }

      child = service.call(command(sire_id: grandpa.id, dam_id: granddaughter.id, name: '近交子'))

      expect(child.health.max).to eq(44)
    end
  end
end
