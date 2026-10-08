# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::EnrichEnclosure do
  describe 'enrichEnclosure(enclosureId:, keeperId:)' do
    subject(:response) do
      OopZooSchema.execute(
        %(mutation { enrichEnclosure(enclosureId: "#{hill.id}", keeperId: "#{keeper.id}") { name enrichment } }),
        context: { current_zoo: zoo }
      ).to_h
    end

    let(:zoo) { create(:zoo) }
    let(:hill) { create(:enclosure, zoo:, name: '丘').deplete_enrichment(60).tap(&:save!) }
    let(:keeper) { create(:keeper, zoo:) }

    it '刺激40の丘に遊具を補充して enrichment=100 で返すこと' do
      expect(response).to eq('data' => { 'enrichEnclosure' => { 'name' => '丘', 'enrichment' => 100 } })
    end

    it '丘の刺激と飼育員の勤務時間を保存すること' do
      response

      expect(hill.reload.enrichment.level).to eq(100)
      expect(keeper.reload.worked_minutes).to eq(Enriching::WORK_MINUTES)
    end
  end
end
