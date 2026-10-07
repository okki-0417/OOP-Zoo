# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Weight do
  describe '.from_kilograms' do
    it '2kg から grams=2000 の Weight を作ること' do
      expect(described_class.from_kilograms(2).grams).to eq(2000)
    end
  end

  describe '.from_tons' do
    it '3t から kilograms=3000 の Weight を作ること' do
      expect(described_class.from_tons(3).kilograms).to eq(3000)
    end
  end

  describe '.from_grams' do
    context '0 を渡したとき' do
      it 'ArgumentError を投げること' do
        expect { described_class.from_grams(0) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#+' do
    it '300g と 200g を足すと 500g になること' do
      expect((described_class.from_grams(300) + described_class.from_grams(200)).grams).to eq(500)
    end
  end

  describe '#<=>' do
    it '2kg は 500g より大きいこと' do
      expect(described_class.from_kilograms(2)).to be > described_class.from_grams(500)
    end
  end

  describe '#to_s' do
    context '1t 以上のとき' do
      it "3t を '3.00t' と表すこと" do
        expect(described_class.from_tons(3).to_s).to eq('3.00t')
      end
    end

    context '1kg 以上 1t 未満のとき' do
      it "2kg を '2.0kg' と表すこと" do
        expect(described_class.from_kilograms(2).to_s).to eq('2.0kg')
      end
    end

    context '1kg 未満のとき' do
      it "50g を '50g' と表すこと" do
        expect(described_class.from_grams(50).to_s).to eq('50g')
      end
    end
  end
end
