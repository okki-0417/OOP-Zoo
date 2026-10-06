# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::Hunger do
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

  describe '.satisfied' do
    it 'level=0(MIN)の Hunger を返すこと' do
      expect(described_class.satisfied.level).to eq(0)
      expect(described_class.satisfied).to be_satisfied
    end
  end

  describe '#increased_by' do
    it 'level=10 に対し increased_by(20) で level=30 になること' do
      expect(described_class.new(10).increased_by(20).level).to eq(30)
    end

    it 'MAX(100)を超えても MAX に丸められること' do
      expect(described_class.new(80).increased_by(50).level).to eq(described_class::MAX)
    end

    it '-1 を渡すと ArgumentError が発生すること' do
      expect { described_class.new(10).increased_by(-1) }.to raise_error(ArgumentError)
    end

    it '元のインスタンスは不変であること' do
      hunger = described_class.new(10)
      hunger.increased_by(5)
      expect(hunger.level).to eq(10)
    end
  end

  describe '#decreased_by' do
    it 'level=50 に対し decreased_by(20) で level=30 になること' do
      expect(described_class.new(50).decreased_by(20).level).to eq(30)
    end

    it 'MIN(0)を下回っても MIN に丸められること' do
      expect(described_class.new(10).decreased_by(50).level).to eq(0)
    end

    it '-1 を渡すと ArgumentError が発生すること' do
      expect { described_class.new(10).decreased_by(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#hungry?' do
    it 'level が HUNGRY_THRESHOLD(70)以上だと true を返すこと' do
      expect(described_class.new(described_class::HUNGRY_THRESHOLD)).to be_hungry
    end

    it 'level が HUNGRY_THRESHOLD 未満だと false を返すこと' do
      expect(described_class.new(described_class::HUNGRY_THRESHOLD - 1)).not_to be_hungry
    end
  end

  describe '#starving?' do
    it 'level が MAX(100)だと true を返すこと' do
      expect(described_class.new(described_class::MAX)).to be_starving
    end

    it 'level が MAX 未満だと false を返すこと' do
      expect(described_class.new(described_class::MAX - 1)).not_to be_starving
    end
  end

  describe '#satisfied?' do
    it 'level=0 だと true を返すこと' do
      expect(described_class.new(0)).to be_satisfied
    end

    it 'level=1 だと false を返すこと' do
      expect(described_class.new(1)).not_to be_satisfied
    end
  end

  describe '大小比較(Comparable)' do
    it 'level の大小で比較されること' do
      expect(described_class.new(10)).to be < described_class.new(20)
    end
  end

  describe '等価性' do
    it '同じ level 同士は eq で等しいこと' do
      expect(described_class.new(10)).to eq(described_class.new(10))
    end
  end
end
