# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::DischargeKeeper do
  shared    = Zoo::Domain::Shared
  taxonomy  = Zoo::Domain
  husbandry = Zoo::Domain
  staff     = Zoo::Domain
  in_memory = Zoo::Infrastructure::InMemory

  let(:keeper) { staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]) }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:keepers) { in_memory::InMemoryKeeperRepository.new([keeper]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:assignments) { in_memory::InMemoryAssignmentRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }

  def discharge(keeper_id: keeper.id, enclosure_id: enclosure.id)
    command = Zoo::Application::Commands::DischargeKeeperCommand.new(keeper_id:, enclosure_id:)
    described_class.new(command: command.bind(keepers:, enclosures:, housings: Factory::HousingRepository.build, assignments:,
                                              unit_of_work:)).call
  end

  def assign
    assignments.save(Zoo::Domain::Tending.new(keeper: keeper, enclosure: enclosure))
  end

  describe '#call' do
    it '担当中のエリアを退任すると success になり現在の担当から外れること' do
      assign

      expect(discharge.success?).to be(true)
      expect(assignments.enclosures_of(keeper)).to be_empty
    end

    it '担当していないエリアの退任は failure で error が AssignmentNotFound となること' do
      expect(discharge.error).to be_a(Zoo::Application::Errors::AssignmentNotFound)
    end

    it '存在しない keeper_id "missing" を渡すと failure で error が KeeperNotFound となること' do
      expect(discharge(keeper_id: 'missing').error).to be_a(Zoo::Application::Errors::KeeperNotFound)
    end

    it '存在しない enclosure_id "missing" を渡すと failure で error が EnclosureNotFound となること' do
      expect(discharge(enclosure_id: 'missing').error).to be_a(Zoo::Application::Errors::EnclosureNotFound)
    end
  end
end
