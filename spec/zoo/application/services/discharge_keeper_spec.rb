# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::DischargeKeeper do
  shared    = Zoo::Domain::Shared
  taxonomy  = Zoo::Domain
  husbandry = Zoo::Domain
  staff     = Zoo::Domain
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:keeper) { staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]) }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:keepers) { in_memory::InMemoryKeeperRepository.new([keeper]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:assignments) { in_memory::InMemoryEnclosureAssignmentRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }
  let(:service) do
    described_class.new(
      keepers: keepers, enclosures: enclosures, assignments: assignments, unit_of_work: unit_of_work
    )
  end

  def assign
    assignments.save(Zoo::Domain::EnclosureAssignment.new(keeper: keeper, enclosure: enclosure))
  end

  describe '#call' do
    it '担当中のエリアを退任すると現在の担当から外れること' do
      assign

      service.call(commands::DischargeKeeperCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id))

      expect(assignments.enclosures_of(keeper)).to be_empty
    end

    it '担当していないエリアの退任は EnclosureAssignmentNotFound が発生すること' do
      command = commands::DischargeKeeperCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id)

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::EnclosureAssignmentNotFound)
    end

    it '存在しない keeper_id を渡すと KeeperNotFound が発生すること' do
      command = commands::DischargeKeeperCommand.new(keeper_id: 'missing', enclosure_id: enclosure.id)

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::KeeperNotFound)
    end

    it '存在しない enclosure_id を渡すと EnclosureNotFound が発生すること' do
      command = commands::DischargeKeeperCommand.new(keeper_id: keeper.id, enclosure_id: 'missing')

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::EnclosureNotFound)
    end
  end
end
