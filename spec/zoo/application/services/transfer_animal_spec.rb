# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::TransferAnimal do
  catalog   = Zoo::Domain::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  def enclosure(name, capacity)
    Zoo::Domain::Enclosure.new(
      name: name, temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: capacity
    )
  end

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:from) { enclosure('丘A', 4).tap { |e| e.admit(lion) } }
  let(:to) { enclosure('丘B', 4) }

  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([from, to]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures, animals]) }
  let(:service) { described_class.new(enclosures: enclosures, animals: animals, unit_of_work: unit_of_work) }

  describe '#call' do
    it '個体を別エリアへ移すと、移送先に収容され移送元から外れること' do
      service.call(commands::TransferAnimalCommand.new(animal_id: lion.id, enclosure_id: to.id))

      expect(enclosures.find(to.id).occupants).to include(lion)
      expect(enclosures.find(from.id).occupants).not_to include(lion)
    end

    it '移送先が満員だと CapacityExceeded になり、個体は移送元に残ること' do
      full = enclosure('満室', 1).tap { |e| e.admit(build_adult(catalog.lion, name: '先住')) }
      enclosures.save(full)

      expect { service.call(commands::TransferAnimalCommand.new(animal_id: lion.id, enclosure_id: full.id)) }
        .to raise_error(Zoo::Domain::Errors::CapacityExceeded)
      expect(enclosures.find(from.id).occupants).to include(lion)
    end
  end
end
