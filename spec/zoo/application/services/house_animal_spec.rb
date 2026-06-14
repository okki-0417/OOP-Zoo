# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::HouseAnimal do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:enclosure) { husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 2) }

  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }
  let(:service) { described_class.new(enclosures: enclosures, animals: animals, unit_of_work: unit_of_work) }

  describe '#call' do
    it 'エリアと動物の id を渡すと、そのエリアの occupants にその動物が含まれること' do
      service.call(commands::HouseAnimalCommand.new(enclosure_id: enclosure.id, animal_id: lion.id))

      expect(enclosures.find(enclosure.id).occupants).to include(lion)
    end

    it '存在しない enclosure_id=\'missing\' を渡すと Application::Errors::EnclosureNotFound が発生すること' do
      command = commands::HouseAnimalCommand.new(enclosure_id: 'missing', animal_id: lion.id)

      expect { service.call(command) }
        .to raise_error(Zoo::Application::Errors::EnclosureNotFound)
    end

    it '存在しない animal_id=\'missing\' を渡すと Application::Errors::AnimalNotFound が発生すること' do
      command = commands::HouseAnimalCommand.new(enclosure_id: enclosure.id, animal_id: 'missing')

      expect { service.call(command) }
        .to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end

    it '定員1の満員エリアに収容しようとすると Domain::Errors::CapacityExceeded が伝播すること' do
      resident = build_adult(catalog.lion, name: '先住')
      full = husbandry::Enclosure.new(name: '小屋', temperature: shared::Temperature.celsius(28), capacity: 1).tap { |e| e.admit(resident) }
      repo = in_memory::InMemoryEnclosureRepository.new([full])
      command = commands::HouseAnimalCommand.new(enclosure_id: full.id, animal_id: lion.id)

      expect { described_class.new(enclosures: repo, animals: animals, unit_of_work: unit_of_work).call(command) }
        .to raise_error(Zoo::Domain::Errors::CapacityExceeded)
    end
  end
end
