# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Enclosure do
  subject(:enclosure) { build(:enclosure, capacity: 3) }

  describe '#area_sqm' do
    it '広さを指定しない定員3のエリアでは 定員×100 の 300 を返すこと' do
      expect(enclosure.area_sqm).to eq(300)
    end
  end

  describe '.construction_cost' do
    context '空調なしのとき' do
      it '定員5 で 基本建設費＋定員×1枠単価 の 80,000円 を返すこと' do
        expect(described_class.construction_cost(capacity: 5)).to eq(Money.yen(80_000))
      end
    end

    context '空調ありのとき' do
      it '定員5 で空調なしより高い額を返すこと' do
        expect(described_class.construction_cost(capacity: 5, climate_controlled: true))
          .to be > described_class.construction_cost(capacity: 5)
      end
    end
  end

  describe '#soil' do
    it 'soil(100) で filthy? を true にすること' do
      expect(enclosure.soil(100)).to be_filthy
    end

    it 'soil(30) で清潔度70にし soiled? を true にすること' do
      expect(enclosure.soil(30)).to be_soiled
    end
  end

  describe '#clean' do
    before { enclosure.soil(100) }

    it 'soil(100) の後に clean(100) すると filthy? を false にすること' do
      expect(enclosure.clean(100)).not_to be_filthy
    end
  end

  describe '#barren?' do
    it '新設のエリアでは false を返すこと' do
      expect(enclosure).not_to be_barren
    end
  end

  describe '#deplete_enrichment' do
    it 'deplete_enrichment(100) で barren? を true にすること' do
      expect(enclosure.deplete_enrichment(100)).to be_barren
    end

    it 'deplete_enrichment(50) で刺激度50にし dull? を true にすること' do
      expect(enclosure.deplete_enrichment(50)).to be_dull
    end
  end

  describe '#enrich' do
    before { enclosure.deplete_enrichment(100) }

    it 'deplete_enrichment(100) の後に enrich(100) すると barren? を false にすること' do
      expect(enclosure.enrich(100)).not_to be_barren
    end
  end
end
