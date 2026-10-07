# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Enclosure::Enrichment do
  describe '.stimulating' do
    it 'level 100 を返すこと' do
      expect(described_class.stimulating.level).to eq(100)
    end
  end

  describe '.new' do
    subject(:enrichment) { described_class.new(level) }

    context '整数でない 1.5 のとき' do
      let(:level) { 1.5 }

      it 'ArgumentError を投げること' do
        expect { enrichment }.to raise_error(ArgumentError)
      end
    end

    context '0 未満の -10 のとき' do
      let(:level) { -10 }

      it 'level を 0 にクランプすること' do
        expect(enrichment.level).to eq(0)
      end
    end

    context '100 超の 150 のとき' do
      let(:level) { 150 }

      it 'level を 100 にクランプすること' do
        expect(enrichment.level).to eq(100)
      end
    end
  end

  describe '#depleted_by' do
    subject(:enrichment) { described_class.new(50) }

    it 'level 50 を 20 減らして 30 にすること' do
      expect(enrichment.depleted_by(20).level).to eq(30)
    end

    context '負の量 -1 のとき' do
      it 'ArgumentError を投げること' do
        expect { enrichment.depleted_by(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#enriched_by' do
    subject(:enrichment) { described_class.new(50) }

    it 'level 50 を 20 増やして 70 にすること' do
      expect(enrichment.enriched_by(20).level).to eq(70)
    end

    context '負の量 -1 のとき' do
      it 'ArgumentError を投げること' do
        expect { enrichment.enriched_by(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#barren?' do
    it 'しきい値の level 30 は true、31 は false を返すこと' do
      expect(described_class.new(30).barren?).to be(true)
      expect(described_class.new(31).barren?).to be(false)
    end
  end

  describe '#dull?' do
    it 'DULL_THRESHOLD の level 50 は true、51 は false を返すこと' do
      expect(described_class.new(50).dull?).to be(true)
      expect(described_class.new(51).dull?).to be(false)
    end
  end

  describe '#==' do
    it '同じ level 40 どうしは等しいこと' do
      expect(described_class.new(40)).to eq(described_class.new(40))
    end
  end
end
