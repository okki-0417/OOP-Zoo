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
  let(:event_store) { in_memory::InMemoryEventStore.new }
  let(:event_dispatcher) { Zoo::Application::EventDispatcher.new(event_store: event_store, subscribers: []) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals]) }
  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: '園', admission_fee: shared::Money.yen(2000))
    )
  end
  let(:service) do
    described_class.new(animals: animals, zoo: zoo,
                        event_dispatcher: event_dispatcher, unit_of_work: unit_of_work)
  end

  def command(sire_id: sire.id, dam_id: dam.id)
    Zoo::Application::Commands::ConceiveAnimalsCommand.new(sire_id: sire_id, dam_id: dam_id)
  end

  describe '#call' do
    it 'sire/dam の id を渡すと dam が妊娠状態になること' do
      service.call(command)
      expect(animals.find(dam.id)).to be_expecting
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
        animals: m_animals, zoo: in_memory::InMemoryZooRepository.new(summer),
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
  end
end
