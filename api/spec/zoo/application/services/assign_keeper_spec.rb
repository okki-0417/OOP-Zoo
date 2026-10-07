# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AssignKeeper do
  catalog = Zoo::Domain::SpeciesCatalog

  let!(:keeper) { Zoo::Domain::Keeper.create!(name: '田中', specialties: [Zoo::Domain::TaxonClass.mammal]) }
  let!(:enclosure) { create_enclosure(name: 'サバンナ') }

  def assign(keeper_id: keeper.id, enclosure_id: enclosure.id)
    described_class.new(command: Zoo::Application::Commands::AssignKeeperCommand.new(keeper_id:, enclosure_id:)).call
  end

  describe '#call' do
    it '専門の綱(哺乳類)のライオンがいるエリアへ担当割り当てすると success になり担当関係が保存されること' do
      build_adult(catalog.lion).move_to(enclosure).save!

      expect(assign.success?).to be(true)
      expect(keeper.reload.enclosures).to contain_exactly(enclosure)
    end

    it '専門外の綱(鳥類)のペンギンがいるエリアへの担当割り当ては failure で error が AssignmentNotAllowed となり保存されないこと' do
      build_adult(catalog.emperor_penguin).move_to(enclosure).save!

      expect(assign.error).to be_a(Zoo::Domain::Errors::AssignmentNotAllowed)
      expect(Zoo::Domain::Assignment.count).to eq(0)
    end

    it 'すでに担当しているエリアへ再度割り当てると failure で error が AssignmentNotAllowed となり担当関係は1件のままであること' do
      assign

      expect(assign.error).to be_a(Zoo::Domain::Errors::AssignmentNotAllowed)
      expect(Zoo::Domain::Assignment.count).to eq(1)
    end

    it '存在しない keeper_id "missing" を渡すと failure で error が KeeperNotFound となること' do
      expect(assign(keeper_id: 'missing').error).to be_a(Zoo::Application::Errors::KeeperNotFound)
    end

    it '存在しない enclosure_id "missing" を渡すと failure で error が EnclosureNotFound となること' do
      expect(assign(enclosure_id: 'missing').error).to be_a(Zoo::Application::Errors::EnclosureNotFound)
    end
  end
end
