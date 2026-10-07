# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::CleanEnclosure do
  let!(:keeper) { create(:keeper, name: '田中') }
  let!(:enclosure) { create(:enclosure).soil(80).tap(&:save!) }

  def clean(command)
    described_class.new(command:).call
  end

  describe '#call' do
    it '清潔度20まで汚れたエリアを amount 50 で清掃すると level が70になり、value の enclosure の cleanliness_level も70であること' do
      result = clean(Services::Commands::CleanEnclosureCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id, amount: 50))

      expect(enclosure.reload.cleanliness.level).to eq(70)
      expect(result.value).to have_attributes(id: enclosure.id, cleanliness_level: 70)
    end

    it 'amount 省略で呼ぶと level が100まで回復し、飼育員の勤務時間60分が保存されること' do
      clean(Services::Commands::CleanEnclosureCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id))

      expect(enclosure.reload.cleanliness.level).to eq(100)
      expect(keeper.reload.worked_minutes).to eq(60)
    end

    it '勤務時間の残っていない飼育員だと WorkNotAllowed の失敗 Result になり、清潔度20のままであること' do
      keeper.clock_in(480).save!

      result = clean(Services::Commands::CleanEnclosureCommand.new(keeper_id: keeper.id, enclosure_id: enclosure.id))

      expect(result.error).to be_a(Errors::WorkNotAllowed)
      expect(enclosure.reload.cleanliness.level).to eq(20)
    end

    it "存在しない keeper_id='missing' を渡すと failure で error が Application::Errors::KeeperNotFound となること" do
      result = clean(Services::Commands::CleanEnclosureCommand.new(keeper_id: 'missing', enclosure_id: enclosure.id))

      expect(result.error).to be_a(Services::Errors::KeeperNotFound)
    end

    it "存在しない enclosure_id='missing' を渡すと failure で error が Application::Errors::EnclosureNotFound となること" do
      result = clean(Services::Commands::CleanEnclosureCommand.new(keeper_id: keeper.id, enclosure_id: 'missing'))

      expect(result.error).to be_a(Services::Errors::EnclosureNotFound)
    end
  end
end
