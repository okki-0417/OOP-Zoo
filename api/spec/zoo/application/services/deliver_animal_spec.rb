# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::DeliverAnimal do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:pair) { build_pair(catalog.lion) }
  let(:sire) { pair[0] }
  let(:dam)  { pair[1] }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end

  let(:animals) { in_memory::InMemoryAnimalRepository.new([sire, dam]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:keepers) { in_memory::InMemoryKeeperRepository.new }
  let(:housings) { in_memory::InMemoryHousingRepository.new }
  let(:breedings) { in_memory::InMemoryBreedingRepository.new }
  let(:births) { in_memory::InMemoryBirthRepository.new }
  let(:unit_of_work) do
    in_memory::InMemoryUnitOfWork.new(repositories: [animals, enclosures, housings, breedings, births])
  end
  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: '園', admission_fee: shared::Money.yen(2000))
    )
  end
  def deliver(dam_id: dam.id, enclosure_id: enclosure.id, keeper_id: nil)
    command = Zoo::Application::Commands::DeliverAnimalCommand.new(dam_id:, enclosure_id:, keeper_id:)
    described_class.new(
      command: command.bind(animals:, enclosures:, housings:, keepers:, breedings:, births:, zoo:, unit_of_work:)
    ).call
  end

  def conceive_dam
    breeding = Zoo::Domain::Breeding.new(sire: sire, dam: dam)
    breeding.conceive
    breedings.save(breeding)
  end

  def prepare_dam_for_delivery
    conceive_dam
    Zoo::Domain::SpeciesCatalog.lion.gestation_period_days.times { dam.gestate }
    animals.save(dam)
  end

  describe '#call' do
    before { prepare_dam_for_delivery }

    it 'dam_id/enclosure_id を渡すと、value の生まれた子が両親を parent_ids に持ちエリアに収容されること' do
      child = deliver.value

      expect(child.parent_ids).to contain_exactly(sire.id, dam.id)
      expect(occupants_of(housings, enclosure)).to include(child)
      expect(animals.find(child.id)).to eq(child)
    end

    it '出産に成功すると Birth が births に1件永続化されること' do
      deliver

      expect(births.all.size).to eq(1)
      expect(births.all.first).to be_a(Zoo::Domain::Birth)
    end

    it '定員1の満員エリアに収容できず failure で error が HousingNotAllowed(定員) になると、子が保存されずロールバックされること' do
      resident = build_adult(catalog.lion, name: '先住')
      full = husbandry::Enclosure.new(name: '小屋', temperature: shared::Temperature.celsius(28), capacity: 1)
      enclosures.save(full)
      housings.save(housed(resident, full))

      error = deliver(enclosure_id: full.id).error

      expect(error).to be_a(Zoo::Domain::Errors::HousingNotAllowed)
      expect(error.message).to match(/定員/)
      expect(animals.all.size).to eq(2)
    end

    it 'ロールバックされた出産の記録は births に残らないこと' do
      resident = build_adult(catalog.lion, name: '先住')
      full = husbandry::Enclosure.new(name: '小屋', temperature: shared::Temperature.celsius(28), capacity: 1)
      enclosures.save(full)
      housings.save(housed(resident, full))

      expect(deliver(enclosure_id: full.id).error).to be_a(Zoo::Domain::Errors::HousingNotAllowed)
      expect(births.all).to be_empty
    end

    it '存在しない dam_id "missing" を渡すと failure で error が AnimalNotFound となること' do
      expect(deliver(dam_id: 'missing').error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end

    it '存在しない enclosure_id "missing" を渡すと failure で error が EnclosureNotFound となること' do
      expect(deliver(enclosure_id: 'missing').error).to be_a(Zoo::Application::Errors::EnclosureNotFound)
    end

    it '存在しない keeper_id "missing" を渡すと failure で error が KeeperNotFound となること' do
      expect(deliver(keeper_id: 'missing').error).to be_a(Zoo::Application::Errors::KeeperNotFound)
    end
  end

  describe '出産準備前の dam' do
    it '受胎済みでも妊娠期間が満ちていない dam は failure で error が BreedingNotAllowed となること' do
      conceive_dam
      animals.save(dam)

      expect(deliver.error).to be_a(Zoo::Domain::Errors::BreedingNotAllowed)
    end

    it '受胎記録のない dam は failure で error が BreedingNotFound となること' do
      expect(deliver.error).to be_a(Zoo::Application::Errors::BreedingNotFound)
    end
  end
end
