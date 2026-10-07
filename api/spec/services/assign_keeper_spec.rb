# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::AssignKeeper do
  let!(:keeper) { create(:keeper, name: '田中') }
  let!(:enclosure) { create(:enclosure, name: 'サバンナ') }

  def assign(keeper_id: keeper.id, enclosure_id: enclosure.id)
    described_class.new(command: Services::Commands::AssignKeeperCommand.new(keeper_id:, enclosure_id:)).call
  end

  describe '#call' do
    it '専門の綱(哺乳類)のライオンがいるエリアへ担当割り当てすると success になり担当関係が保存されること' do
      build(:animal).move_to(enclosure).save!

      expect(assign.success?).to be(true)
      expect(keeper.reload.enclosures).to contain_exactly(enclosure)
    end

    it '専門外の綱(鳥類)のペンギンがいるエリアへの担当割り当ては failure で error が AssignmentNotAllowed となり保存されないこと' do
      build(:animal, species: SpeciesCatalog.emperor_penguin).move_to(enclosure).save!

      expect(assign.error).to be_a(Errors::AssignmentNotAllowed)
      expect(Assignment.count).to eq(0)
    end

    it 'すでに担当しているエリアへ再度割り当てると failure で error が AssignmentNotAllowed となり担当関係は1件のままであること' do
      assign

      expect(assign.error).to be_a(Errors::AssignmentNotAllowed)
      expect(Assignment.count).to eq(1)
    end

    it '存在しない keeper_id "missing" を渡すと failure で error が KeeperNotFound となること' do
      expect(assign(keeper_id: 'missing').error).to be_a(Services::Errors::KeeperNotFound)
    end

    it '存在しない enclosure_id "missing" を渡すと failure で error が EnclosureNotFound となること' do
      expect(assign(enclosure_id: 'missing').error).to be_a(Services::Errors::EnclosureNotFound)
    end
  end
end
