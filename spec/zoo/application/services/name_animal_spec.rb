# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::NameAnimal do
  shared    = Zoo::Domain::Shared
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:animal) { build_adult(catalog.lion, name: 'ライオンの赤ちゃん', sex: Zoo::Domain::Animal::Sex.female) }

  let(:animals) { in_memory::InMemoryAnimalRepository.new([animal]) }
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

  def command(animal_id: animal.id, name: 'ナラ', keeper_id: nil)
    Zoo::Application::Commands::NameAnimalCommand.new(
      animal_id: animal_id, name: name, keeper_id: keeper_id
    )
  end

  describe '#call' do
    it '動物の名前が更新されること' do
      service.call(command(name: 'ナラ'))
      expect(animals.find(animal.id).name.to_s).to eq('ナラ')
    end

    it '命名が namings に1件永続化されること' do
      service.call(command(name: 'ナラ'))
      expect(animals.namings.size).to eq(1)
      expect(animals.namings.first).to be_a(Zoo::Domain::Events::AnimalNamed)
      expect(animals.namings.first.name).to eq('ナラ')
    end

    it '存在しない animal_id を渡すと AnimalNotFound が発生すること' do
      expect { service.call(command(animal_id: 'missing')) }
        .to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end

    it '存在しない keeper_id を渡すと KeeperNotFound が発生すること' do
      expect { service.call(command(keeper_id: 'missing')) }
        .to raise_error(Zoo::Application::Errors::KeeperNotFound)
    end
  end
end
