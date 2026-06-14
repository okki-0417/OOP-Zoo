# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::RenameAnimal do
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  commands  = Zoo::Application::Commands
  events    = Zoo::Domain::Events
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:event_store) { in_memory::InMemoryEventStore.new }
  let(:dispatcher) { Zoo::Application::EventDispatcher.new(event_store: event_store) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals]) }
  let(:service) { described_class.new(animals: animals, event_dispatcher: dispatcher, unit_of_work: unit_of_work) }

  describe '#call' do
    it '改名すると名前が変わり、AnimalRenamed が EventStore に記録されること' do
      service.call(commands::RenameAnimalCommand.new(animal_id: lion.id, new_name: 'シンバ'))

      expect(animals.find(lion.id).name.to_s).to eq('シンバ')
      expect(event_store.all.last).to be_a(events::AnimalRenamed)
    end

    it '存在しない animal_id で Application::Errors::AnimalNotFound が発生すること' do
      command = commands::RenameAnimalCommand.new(animal_id: 'missing', new_name: 'X')

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
