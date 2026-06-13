# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Husbandry::Cleanliness do
  describe '.new' do
    it '50 を渡すと level が 50 を返すこと' do
      expect(described_class.new(50).level).to eq(50)
    end

    it 'MAX(100)を超える値は MAX に丸められること' do
      expect(described_class.new(999).level).to eq(described_class::MAX)
    end

    it 'MIN(0)未満の値は MIN に丸められること' do
      expect(described_class.new(-50).level).to eq(described_class::MIN)
    end

    it 'Integer 以外を渡すと ArgumentError が発生すること' do
      expect { described_class.new(1.5) }.to raise_error(ArgumentError)
    end
  end

  describe '.spotless' do
    it 'level=MAX(100)の Cleanliness を返すこと' do
      expect(described_class.spotless.level).to eq(described_class::MAX)
    end
  end

  describe '#soiled_by' do
    it 'level=100 に soiled_by(30) で level=70 になること' do
      expect(described_class.spotless.soiled_by(30).level).to eq(70)
    end

    it 'MIN(0)を下回っても MIN に丸められること' do
      expect(described_class.new(10).soiled_by(50).level).to eq(0)
    end

    it '-1 を渡すと ArgumentError が発生すること' do
      expect { described_class.spotless.soiled_by(-1) }.to raise_error(ArgumentError)
    end

    it '元のインスタンスは不変であること' do
      cleanliness = described_class.spotless
      cleanliness.soiled_by(30)
      expect(cleanliness.level).to eq(described_class::MAX)
    end
  end

  describe '#cleaned_by' do
    it 'level=50 に cleaned_by(30) で level=80 になること' do
      expect(described_class.new(50).cleaned_by(30).level).to eq(80)
    end

    it 'MAX(100)を超えても MAX に丸められること' do
      expect(described_class.new(80).cleaned_by(50).level).to eq(described_class::MAX)
    end

    it '-1 を渡すと ArgumentError が発生すること' do
      expect { described_class.spotless.cleaned_by(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#filthy?' do
    it 'level が FILTHY_THRESHOLD(30)以下だと true を返すこと' do
      expect(described_class.new(described_class::FILTHY_THRESHOLD)).to be_filthy
    end

    it 'level が FILTHY_THRESHOLD を超えると false を返すこと' do
      expect(described_class.new(described_class::FILTHY_THRESHOLD + 1)).not_to be_filthy
    end
  end

  describe '大小比較(Comparable)' do
    it 'level の大小で比較されること' do
      expect(described_class.new(10)).to be < described_class.new(20)
    end
  end

  describe '等価性' do
    it '同じ level 同士は eq で等しいこと' do
      expect(described_class.new(50)).to eq(described_class.new(50))
    end
  end
end
