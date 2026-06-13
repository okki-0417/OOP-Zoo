# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Shared::Money do
  describe '.new' do
    it '1000 を渡すと yen が 1000 を返すこと' do
      expect(described_class.new(1000).yen).to eq(1000)
    end

    it '0 を渡しても ArgumentError にならないこと(零円は許容)' do
      expect { described_class.new(0) }.not_to raise_error
    end

    it '-1 を渡すと ArgumentError が発生すること' do
      expect { described_class.new(-1) }.to raise_error(ArgumentError)
    end

    it 'Integer 以外(例: 1.5)を渡すと ArgumentError が発生すること' do
      expect { described_class.new(1.5) }.to raise_error(ArgumentError)
    end
  end

  describe '.zero' do
    it 'yen=0 の Money を返すこと' do
      expect(described_class.zero.yen).to eq(0)
    end
  end

  describe '.yen(amount)' do
    it '.new(amount) と等しい Money を返すこと' do
      expect(described_class.yen(2000)).to eq(described_class.new(2000))
    end
  end

  describe '#+' do
    it 'Money(1000) + Money(500) の yen は 1500 を返すこと' do
      sum = described_class.new(1000) + described_class.new(500)
      expect(sum.yen).to eq(1500)
    end

    it '元のインスタンスは不変であること' do
      a = described_class.new(1000)
      a + described_class.new(500)
      expect(a.yen).to eq(1000)
    end
  end

  describe '#*' do
    it 'Money(1000) * 3 の yen は 3000 を返すこと' do
      expect((described_class.new(1000) * 3).yen).to eq(3000)
    end

    it '0 を掛けても yen=0 を返すこと' do
      expect((described_class.new(1000) * 0).yen).to eq(0)
    end

    it '-1 を渡すと ArgumentError が発生すること' do
      expect { described_class.new(1000) * -1 }.to raise_error(ArgumentError)
    end

    it 'Integer 以外を渡すと ArgumentError が発生すること' do
      expect { described_class.new(1000) * 1.5 }.to raise_error(ArgumentError)
    end
  end

  describe '#to_s' do
    it "1000 円は '¥1,000' を返すこと(3桁ごとカンマ区切り)" do
      expect(described_class.new(1000).to_s).to eq('¥1,000')
    end

    it "100 円は '¥100' を返すこと(カンマ無し)" do
      expect(described_class.new(100).to_s).to eq('¥100')
    end

    it "1234567 円は '¥1,234,567' を返すこと" do
      expect(described_class.new(1_234_567).to_s).to eq('¥1,234,567')
    end
  end

  describe '大小比較(Comparable)' do
    it 'yen の大小で比較されること' do
      expect(described_class.new(1000)).to be < described_class.new(2000)
    end
  end

  describe '等価性' do
    it '同じ yen 同士は eq で等しいこと' do
      expect(described_class.new(1000)).to eq(described_class.new(1000))
    end
  end
end
