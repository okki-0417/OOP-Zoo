# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AssignKeeper do
  shared    = Zoo::Domain::Shared
  taxonomy  = Zoo::Domain
  husbandry = Zoo::Domain
  staff     = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:keeper) { staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]) }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:keepers) { in_memory::InMemoryKeeperRepository.new([keeper]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new }
  let(:assignments) { in_memory::InMemoryAssignmentRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }

  def assign(keeper_id: keeper.id, enclosure_id: enclosure.id)
    command = Zoo::Application::Commands::AssignKeeperCommand.new(keeper_id:, enclosure_id:)
    described_class.new(
      command: command.bind(keepers:, enclosures:, housings:, assignments:, unit_of_work:)
    ).call
  end

  def house(animal, enclosure)
    occupancy = build_occupancy(enclosure, housings.occupants_of(enclosure))
    housings.save(Zoo::Domain::Housing.new(animal: animal, enclosure: enclosure, occupancy: occupancy))
  end

  describe '#call' do
    it '専門の綱(哺乳類)のライオンがいるエリアへ担当割り当てすると success になり assignments に保存されること' do
      house(build_adult(catalog.lion), enclosure)

      expect(assign.success?).to be(true)
      expect(assignments.enclosures_of(keeper)).to contain_exactly(enclosure)
    end

    it '専門外の綱(鳥類)のペンギンがいるエリアへの担当割り当ては failure で error が AssignmentNotAllowed となり保存されないこと' do
      house(build_adult(catalog.emperor_penguin), enclosure)

      expect(assign.error).to be_a(Zoo::Domain::Errors::AssignmentNotAllowed)
      expect(assignments.all).to be_empty
    end

    it '存在しない keeper_id "missing" を渡すと failure で error が KeeperNotFound となること' do
      expect(assign(keeper_id: 'missing').error).to be_a(Zoo::Application::Errors::KeeperNotFound)
    end

    it '存在しない enclosure_id "missing" を渡すと failure で error が EnclosureNotFound となること' do
      expect(assign(enclosure_id: 'missing').error).to be_a(Zoo::Application::Errors::EnclosureNotFound)
    end
  end
end
