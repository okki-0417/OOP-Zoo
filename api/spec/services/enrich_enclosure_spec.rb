# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::EnrichEnclosure do
  let!(:keeper) { create(:keeper) }
  let!(:hill) { create(:enclosure, celsius: 24).deplete_enrichment(60).tap(&:save!) }

  def enrich(keeper_id: keeper.id, enclosure_id: hill.id)
    command = Services::Commands::EnrichEnclosureCommand.new(keeper_id:, enclosure_id:)
    described_class.new(command:).call
  end

  describe '#call' do
    it '刺激度40のエリアを100に戻し、enrichment.level=100・barren?=false のエリアを返して飼育員の勤務時間30分を保存すること' do
      enclosure = enrich.value

      expect(enclosure.enrichment.level).to eq(100)
      expect(enclosure).not_to be_barren
      expect(hill.reload.enrichment.level).to eq(100)
      expect(keeper.reload.worked_minutes).to eq(30)
    end

    it "存在しない keeper_id / enclosure_id 'missing' はそれぞれ KeeperNotFound / EnclosureNotFound になること" do
      expect(enrich(keeper_id: 'missing').error).to be_a(Services::Errors::KeeperNotFound)
      expect(enrich(enclosure_id: 'missing').error).to be_a(Services::Errors::EnclosureNotFound)
    end

    it '勤務時間の残っていない飼育員は WorkNotAllowed の失敗 Result になること' do
      keeper.clock_in(480).save!

      expect(enrich.error).to be_a(Errors::WorkNotAllowed)
    end
  end
end
