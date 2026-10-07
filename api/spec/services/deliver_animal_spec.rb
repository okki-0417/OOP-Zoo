# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::DeliverAnimal do
  let!(:zoo) { create(:zoo) }
  let!(:sire) { create(:animal) }
  let!(:dam) { create(:animal, :female) }
  let!(:enclosure) { create(:enclosure) }

  def deliver(dam_id: dam.id, enclosure_id: enclosure.id, keeper_id: nil)
    command = Services::Commands::DeliverAnimalCommand.new(dam_id:, enclosure_id:, keeper_id:)
    described_class.new(command:).call
  end

  def conceive_dam
    Breeding.new(sire:, dam:).conceive.save!
    dam.save!
  end

  def prepare_dam_for_delivery
    conceive_dam
    SpeciesCatalog.lion.gestation_period_days.times { dam.gestate }
    dam.save!
  end

  def full_enclosure
    create(:enclosure, name: '小屋', capacity: 1).tap do |full|
      build(:animal, name: '先住').move_to(full).save!
    end
  end

  describe '#call' do
    before { prepare_dam_for_delivery }

    it 'dam_id/enclosure_id を渡すと、value の生まれた子が両親を parents に持ちエリアに収容されて保存されること' do
      child = deliver.value

      expect(child.reload.parents).to contain_exactly(sire, dam)
      expect(enclosure.animals.reload).to include(child)
      expect(dam.reload).not_to be_expecting
    end

    it '出産に成功すると話題性(buzz)が 40 上がって保存されること' do
      deliver

      expect(zoo.reload.buzz).to eq(40)
    end

    it '定員1の満員エリアに収容できず failure で error が HousingNotAllowed(定員) になると、子が保存されずロールバックされること' do
      full = full_enclosure

      error = deliver(enclosure_id: full.id).error

      expect(error).to be_a(Errors::HousingNotAllowed)
      expect(error.message).to match(/定員/)
      expect(Animal.count).to eq(3)
    end

    it 'ロールバックされた出産では dam は妊娠したままで、buzz も 0 のままであること' do
      expect(deliver(enclosure_id: full_enclosure.id).error).to be_a(Errors::HousingNotAllowed)
      expect(dam.reload).to be_expecting
      expect(zoo.reload.buzz).to eq(0)
    end

    it '存在しない dam_id "missing" を渡すと failure で error が AnimalNotFound となること' do
      expect(deliver(dam_id: 'missing').error).to be_a(Services::Errors::AnimalNotFound)
    end

    it '存在しない enclosure_id "missing" を渡すと failure で error が EnclosureNotFound となること' do
      expect(deliver(enclosure_id: 'missing').error).to be_a(Services::Errors::EnclosureNotFound)
    end

    it '存在しない keeper_id "missing" を渡すと failure で error が KeeperNotFound となること' do
      expect(deliver(keeper_id: 'missing').error).to be_a(Services::Errors::KeeperNotFound)
    end
  end

  describe '出産準備前の dam' do
    it '受胎済みでも妊娠期間が満ちていない dam は failure で error が BreedingNotAllowed となること' do
      conceive_dam

      expect(deliver.error).to be_a(Errors::BreedingNotAllowed)
    end

    it '受胎記録のない dam は failure で error が BreedingNotFound となること' do
      expect(deliver.error).to be_a(Services::Errors::BreedingNotFound)
    end
  end
end
