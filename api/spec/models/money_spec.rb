# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Money do
  describe '.new' do
    subject(:money) { described_class.new(yen) }

    context '1000 のとき' do
      let(:yen) { 1000 }

      it 'yen が 1000 を返すこと' do
        expect(money.yen).to eq(1000)
      end
    end

    context '0 のとき' do
      let(:yen) { 0 }

      it 'ArgumentError にならないこと' do
        expect { money }.not_to raise_error
      end
    end

    context '-1 のとき' do
      let(:yen) { -1 }

      it 'ArgumentError を投げること' do
        expect { money }.to raise_error(ArgumentError)
      end
    end

    context 'Integer でない 1.5 のとき' do
      let(:yen) { 1.5 }

      it 'ArgumentError を投げること' do
        expect { money }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.zero' do
    it 'yen=0 の Money を返すこと' do
      expect(described_class.zero.yen).to eq(0)
    end
  end

  describe '.yen' do
    it '.yen(2000) は .new(2000) と等しい Money を返すこと' do
      expect(described_class.yen(2000)).to eq(described_class.new(2000))
    end
  end

  describe '#+' do
    let(:thousand) { described_class.new(1000) }

    it 'Money(1000) + Money(500) は yen 1500 の Money を返すこと' do
      expect((thousand + described_class.new(500)).yen).to eq(1500)
    end

    it '足しても元の Money(1000) は 1000 のままであること' do
      expect { thousand + described_class.new(500) }.not_to change(thousand, :yen).from(1000)
    end
  end

  describe '#*' do
    subject(:product) { described_class.new(1000) * factor }

    context '3 のとき' do
      let(:factor) { 3 }

      it 'yen 3000 の Money を返すこと' do
        expect(product.yen).to eq(3000)
      end
    end

    context '0 のとき' do
      let(:factor) { 0 }

      it 'yen 0 の Money を返すこと' do
        expect(product.yen).to eq(0)
      end
    end

    context '-1 のとき' do
      let(:factor) { -1 }

      it 'ArgumentError を投げること' do
        expect { product }.to raise_error(ArgumentError)
      end
    end

    context 'Integer でない 1.5 のとき' do
      let(:factor) { 1.5 }

      it 'ArgumentError を投げること' do
        expect { product }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#to_s' do
    subject(:text) { described_class.new(yen).to_s }

    context '4桁の 1000 円のとき' do
      let(:yen) { 1000 }

      it "3桁ごとにカンマを入れた '¥1,000' を返すこと" do
        expect(text).to eq('¥1,000')
      end
    end

    context '3桁の 100 円のとき' do
      let(:yen) { 100 }

      it "カンマのない '¥100' を返すこと" do
        expect(text).to eq('¥100')
      end
    end

    context '7桁の 1234567 円のとき' do
      let(:yen) { 1_234_567 }

      it "'¥1,234,567' を返すこと" do
        expect(text).to eq('¥1,234,567')
      end
    end
  end

  describe '#<=>' do
    it 'Money(1000) < Money(2000) となること' do
      expect(described_class.new(1000)).to be < described_class.new(2000)
    end
  end

  describe '#==' do
    it '同じ yen 1000 どうしは等しいこと' do
      expect(described_class.new(1000)).to eq(described_class.new(1000))
    end
  end
end
