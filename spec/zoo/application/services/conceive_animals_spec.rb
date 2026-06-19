# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::ConceiveAnimals do
  shared    = Zoo::Domain::Shared
  animal    = Zoo::Domain::Animal
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:pair) { build_pair(catalog.lion) }
  let(:sire) { pair[0] }
  let(:dam)  { pair[1] }

  let(:animals) { in_memory::InMemoryAnimalRepository.new([sire, dam]) }
  let(:keepers) { in_memory::InMemoryKeeperRepository.new }
  let(:event_store) { in_memory::InMemoryEventStore.new }
  let(:event_dispatcher) { Zoo::Application::EventDispatcher.new(event_store: event_store, subscribers: []) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals]) }
  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: '園', admission_fee: shared::Money.yen(2000))
    )
  end
  let(:service) do
    described_class.new(animals: animals, keepers: keepers, zoo: zoo,
                        event_dispatcher: event_dispatcher, unit_of_work: unit_of_work)
  end

  def command(sire_id: sire.id, dam_id: dam.id, keeper_id: nil)
    Zoo::Application::Commands::ConceiveAnimalsCommand.new(
      sire_id: sire_id, dam_id: dam_id, keeper_id: keeper_id
    )
  end

  describe '#call' do
    it 'sire/dam の id を渡すと dam が妊娠状態になること' do
      service.call(command)
      expect(animals.find(dam.id)).to be_expecting
    end

    it '受胎が conceptions に1件永続化されること' do
      service.call(command)
      expect(animals.conceptions.size).to eq(1)
      expect(animals.conceptions.first).to be_a(Zoo::Domain::Events::AnimalConceived)
    end

    it '血統から近交係数を求め、conception に inbreeding_coefficient が記録されること' do
      grandpa = animal.new(species: catalog.lion, name: '祖父', sex: animal::Sex.male,
                           max_health: 100, age_in_days: 4000)
      grandma = animal.new(species: catalog.lion, name: '祖母', sex: animal::Sex.female,
                           max_health: 100, age_in_days: 6000)
      mother = animal.new(species: catalog.lion, name: '母', sex: animal::Sex.female,
                          max_health: 100, age_in_days: 3000,
                          sire_id: grandpa.id, dam_id: grandma.id)
      outsider = animal.new(species: catalog.lion, name: '外', sex: animal::Sex.male,
                            max_health: 100, age_in_days: 6000)
      granddaughter = animal.new(species: catalog.lion, name: '孫娘', sex: animal::Sex.female,
                                 max_health: 100, age_in_days: 1200,
                                 sire_id: outsider.id, dam_id: mother.id)
      [grandpa, grandma, mother, outsider, granddaughter].each { |a| animals.save(a) }

      service.call(command(sire_id: grandpa.id, dam_id: granddaughter.id))

      expect(animals.conceptions.last.inbreeding_coefficient).to be > 0.0
    end

    it 'オス同士を渡すと BreedingNotAllowed が伝播すること' do
      other_male = build_adult(catalog.lion, name: 'もう一頭', sex: animal::Sex.male)
      animals.save(other_male)

      expect { service.call(command(dam_id: other_male.id)) }
        .to raise_error(Zoo::Domain::Errors::BreedingNotAllowed)
    end

    it '季節繁殖種(ニホンザル=秋)は繁殖季節でない季節には BreedingNotAllowed になること' do
      macaque = catalog.japanese_macaque
      m_sire, m_dam = build_pair(macaque)
      m_animals = in_memory::InMemoryAnimalRepository.new([m_sire, m_dam])

      summer = Zoo::Domain::Zoo.new(name: '園', admission_fee: shared::Money.yen(2000))
      100.times { summer.advance_day }
      m_service = described_class.new(
        animals: m_animals, keepers: keepers, zoo: in_memory::InMemoryZooRepository.new(summer),
        event_dispatcher: event_dispatcher,
        unit_of_work: in_memory::InMemoryUnitOfWork.new(repositories: [m_animals])
      )

      expect do
        m_service.call(Zoo::Application::Commands::ConceiveAnimalsCommand.new(
                         sire_id: m_sire.id, dam_id: m_dam.id
                       ))
      end.to raise_error(Zoo::Domain::Errors::BreedingNotAllowed)
    end

    it '存在しない sire_id を渡すと AnimalNotFound が発生すること' do
      expect { service.call(command(sire_id: 'missing')) }
        .to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end

    it '存在しない keeper_id を渡すと KeeperNotFound が発生すること' do
      expect { service.call(command(keeper_id: 'missing')) }
        .to raise_error(Zoo::Application::Errors::KeeperNotFound)
    end
  end
end
