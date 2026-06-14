# frozen_string_literal: true

require 'spec_helper'

# Stress 値オブジェクトの実装上の保証(クランプ・異常系・等価性・しきい値)。
# ドメインとしての福祉の意味は spec/knowledge/ の「動物」「動物福祉」を参照。
RSpec.describe Zoo::Domain::Animal::Stress do
  describe '.calm' do
    it '穏やか(0)の Stress を返すこと' do
      expect(described_class.calm.level).to eq(0)
      expect(described_class.calm).to be_calm
    end
  end

  describe '#initialize' do
    it '0未満は0にクランプされること' do
      expect(described_class.new(-10).level).to eq(0)
    end

    it '100超は100にクランプされること' do
      expect(described_class.new(150).level).to eq(100)
    end

    it '整数以外は ArgumentError になること' do
      expect { described_class.new(1.5) }.to raise_error(ArgumentError)
    end
  end

  describe '#increased_by' do
    it '負の増加量は ArgumentError になること' do
      expect { described_class.new(10).increased_by(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#decreased_by' do
    it '負の減少量は ArgumentError になること' do
      expect { described_class.new(10).decreased_by(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#stressed?' do
    it 'しきい値60を境に切り替わること' do
      expect(described_class.new(60)).to be_stressed
      expect(described_class.new(59)).not_to be_stressed
    end
  end

  describe '#severe?' do
    it 'しきい値90を境に切り替わること' do
      expect(described_class.new(90)).to be_severe
      expect(described_class.new(89)).not_to be_severe
    end
  end

  describe '等価性' do
    it '同じ値どうしは等価であること' do
      expect(described_class.new(50)).to eq(described_class.new(50))
    end

    it '値で大小比較できること' do
      expect(described_class.new(60)).to be > described_class.new(50)
    end
  end

  describe '#to_s' do
    it '"値/100" の形で表されること' do
      expect(described_class.new(40).to_s).to eq('40/100')
    end
  end
end
