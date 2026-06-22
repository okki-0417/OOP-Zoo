# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AssignKeeper do
  shared    = Zoo::Domain::Shared
  taxonomy  = Zoo::Domain
  husbandry = Zoo::Domain
  staff     = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:keeper) { staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]) }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:keepers) { in_memory::InMemoryKeeperRepository.new([keeper]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new }
  let(:assignments) { in_memory::InMemoryEnclosureAssignmentRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }
  let(:service) do
    described_class.new(
      keepers: keepers, enclosures: enclosures, housings: housings,
      assignments: assignments, unit_of_work: unit_of_work
    )
  end

  def house(animal, enclosure)
    occupancy = Zoo::Domain::Occupancy.new(enclosure, housings.occupants_of(enclosure))
    housings.save(Zoo::Domain::Housing.new(animal: animal, enclosure: enclosure, occupancy: occupancy))
  end

  describe '#call' do
    it '専門の綱の動物がいるエリアへ担当割り当てすると assignments に保存されること' do
      house(build_adult(catalog.lion), enclosure)

      service.call(commands::AssignKeeperCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id))

      expect(assignments.enclosures_of(keeper)).to contain_exactly(enclosure)
    end

    it '専門外の綱の動物がいるエリアへの担当割り当ては EnclosureAssignmentNotAllowed で保存されないこと' do
      house(build_adult(catalog.emperor_penguin), enclosure)

      command = commands::AssignKeeperCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id)

      expect { service.call(command) }.to raise_error(Zoo::Domain::Errors::EnclosureAssignmentNotAllowed)
      expect(assignments.all).to be_empty
    end

    it '存在しない keeper_id を渡すと KeeperNotFound が発生すること' do
      command = commands::AssignKeeperCommand.new(keeper_id: 'missing', enclosure_id: enclosure.id)

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::KeeperNotFound)
    end

    it '存在しない enclosure_id を渡すと EnclosureNotFound が発生すること' do
      command = commands::AssignKeeperCommand.new(keeper_id: keeper.id, enclosure_id: 'missing')

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::EnclosureNotFound)
    end
  end
end
