# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Shared::Health do
  describe '.full' do
    it '最大体力で満タンのHealthを生成すること' do
      health = described_class.full(10)
      expect(health.current).to eq(10)
      expect(health.max).to eq(10)
      expect(health).to be_full
    end
  end

  describe '#initialize' do
    it '最大体力が0以下だとエラーになること' do
      expect { described_class.new(current: 0, max: 0) }.to raise_error(ArgumentError)
    end

    it '現在体力は0〜最大値に丸められること' do
      expect(described_class.new(current: 999, max: 10).current).to eq(10)
      expect(described_class.new(current: -5, max: 10).current).to eq(0)
    end
  end

  describe '#decreased_by' do
    let(:health) { described_class.full(10) }

    it '体力を減らした新しいHealthを返すこと' do
      expect(health.decreased_by(3).current).to eq(7)
    end

    it '0未満にはならないこと' do
      expect(health.decreased_by(999).current).to eq(0)
    end

    it '元のHealthは変化しないこと(不変)' do
      health.decreased_by(3)
      expect(health.current).to eq(10)
    end

    it 'マイナスの減少量はエラーになること' do
      expect { health.decreased_by(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#increased_by' do
    let(:health) { described_class.new(current: 5, max: 10) }

    it '最大値を超えないこと' do
      expect(health.increased_by(999).current).to eq(10)
    end
  end

  describe '#weak?' do
    it '20%以下のとき衰弱とみなすこと' do
      expect(described_class.new(current: 2, max: 10)).to be_weak
      expect(described_class.new(current: 3, max: 10)).not_to be_weak
    end
  end

  describe '#empty?' do
    it '体力が尽きているとき真を返すこと' do
      expect(described_class.new(current: 0, max: 10)).to be_empty
    end
  end

  describe '等価性' do
    it '現在値と最大値が同じなら等しいこと' do
      expect(described_class.new(current: 5, max: 10)).to eq(described_class.new(current: 5, max: 10))
    end

    it 'ハッシュのキーとして使えること' do
      a = described_class.new(current: 5, max: 10)
      b = described_class.new(current: 5, max: 10)
      expect({ a => :x }[b]).to eq(:x)
    end
  end
end
