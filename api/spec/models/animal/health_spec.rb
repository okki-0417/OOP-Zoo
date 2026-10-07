# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::Health do
  subject(:health) { described_class.new(current:, max:) }

  let(:current) { 10 }
  let(:max) { 10 }

  describe '.full' do
    it 'full(10) は current=10・max=10 で full? が true の Health を返すこと' do
      expect(described_class.full(10)).to have_attributes(current: 10, max: 10, full?: true)
    end
  end

  describe '.new' do
    context 'max が0のとき' do
      let(:current) { 0 }
      let(:max) { 0 }

      it 'ArgumentError を投げること' do
        expect { health }.to raise_error(ArgumentError)
      end
    end

    context 'current が max を超える999のとき' do
      let(:current) { 999 }

      it 'current を max の10に丸めること' do
        expect(health.current).to eq(10)
      end
    end

    context 'current が負の-5のとき' do
      let(:current) { -5 }

      it 'current を0に丸めること' do
        expect(health.current).to eq(0)
      end
    end
  end

  describe '#decreased_by' do
    it '10/10 から3減らすと current=7 の新しい Health を返し、元は10のままであること' do
      expect(health.decreased_by(3).current).to eq(7)
      expect(health.current).to eq(10)
    end

    context '減少量が current を超える999のとき' do
      it 'current=0 で止まること' do
        expect(health.decreased_by(999).current).to eq(0)
      end
    end

    context '減少量が負の-1のとき' do
      it 'ArgumentError を投げること' do
        expect { health.decreased_by(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#increased_by' do
    let(:current) { 5 }

    it '5/10 に999足しても current=10 で止まること' do
      expect(health.increased_by(999).current).to eq(10)
    end
  end

  describe '#weak?' do
    context '最大の20%の 2/10 のとき' do
      let(:current) { 2 }

      it 'true を返すこと' do
        expect(health).to be_weak
      end
    end

    context '最大の20%を超える 3/10 のとき' do
      let(:current) { 3 }

      it 'false を返すこと' do
        expect(health).not_to be_weak
      end
    end
  end

  describe '#empty?' do
    let(:current) { 0 }

    it '0/10 では true を返すこと' do
      expect(health).to be_empty
    end
  end

  describe '#== / #hash' do
    let(:current) { 5 }
    let(:other) { described_class.new(current: 5, max: 10) }

    it '5/10 同士は等しく、ハッシュのキーとして同じ値を引けること' do
      expect(health).to eq(other)
      expect({ health => :x }[other]).to eq(:x)
    end
  end
end
