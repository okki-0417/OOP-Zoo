# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Enriching do
  subject(:enriching) { described_class.new(keeper:, enclosure:) }

  let(:keeper) { build(:keeper, name: '飼育員') }
  let(:enclosure) { build(:enclosure, name: '丘') }

  describe '#perform' do
    before { enclosure.deplete_enrichment(80) }

    context '勤務時間が残っているとき' do
      it '刺激度 20 のエリアを 100 に戻し、飼育員の勤務時間を 30 分使うこと' do
        enriching.perform

        expect(enclosure.enrichment.level).to eq(100)
        expect(keeper.worked_minutes).to eq(30)
      end
    end

    context '残り勤務時間が 29 分のとき' do
      before { keeper.clock_in(451) }

      it 'WorkNotAllowed を投げ、刺激度を 20 のままにすること' do
        expect { enriching.perform }.to raise_error(Errors::WorkNotAllowed)
        expect(enclosure.enrichment.level).to eq(20)
      end
    end
  end

  describe '#to_s' do
    it '"飼育員が丘に遊具を補充" を返すこと' do
      expect(enriching.to_s).to eq('飼育員が丘に遊具を補充')
    end
  end
end
