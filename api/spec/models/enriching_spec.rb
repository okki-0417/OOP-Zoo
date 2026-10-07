# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Enriching do
  let(:keeper) { build_keeper }
  let(:enclosure) do
    Enclosure.new(name: '丘', temperature: Temperature.celsius(24), capacity: 4)
  end

  describe '#perform' do
    it '刺激度20のエリアを100に戻し、飼育員の勤務時間を30分使うこと' do
      enclosure.deplete_enrichment(80)
      described_class.new(keeper:, enclosure:).perform

      expect(enclosure.enrichment.level).to eq(100)
      expect(keeper.worked_minutes).to eq(30)
    end

    it '残り勤務時間が29分なら WorkNotAllowed になり、刺激度は変わらないこと' do
      enclosure.deplete_enrichment(80)
      keeper.clock_in(451)

      expect { described_class.new(keeper:, enclosure:).perform }.to raise_error(Errors::WorkNotAllowed)
      expect(enclosure.enrichment.level).to eq(20)
    end
  end

  describe '#to_s' do
    it '"飼育員が丘に遊具を補充" を返すこと' do
      expect(described_class.new(keeper:, enclosure:).to_s).to eq('飼育員が丘に遊具を補充')
    end
  end
end
