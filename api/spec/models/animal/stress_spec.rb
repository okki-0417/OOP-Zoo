# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::Stress do
  subject(:stress) { described_class.new(level) }

  let(:level) { 40 }

  describe '.calm' do
    it 'level 0 で calm? が true の Stress を返すこと' do
      expect(described_class.calm.level).to eq(0)
      expect(described_class.calm).to be_calm
    end
  end

  describe '.new' do
    context '-10 を渡したとき' do
      let(:level) { -10 }

      it 'level を 0 にクランプすること' do
        expect(stress.level).to eq(0)
      end
    end

    context '150 を渡したとき' do
      let(:level) { 150 }

      it 'level を 100 にクランプすること' do
        expect(stress.level).to eq(100)
      end
    end

    context '整数でない 1.5 を渡したとき' do
      let(:level) { 1.5 }

      it 'ArgumentError を投げること' do
        expect { stress }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#increased_by' do
    it '負の増加量 -1 で ArgumentError を投げること' do
      expect { stress.increased_by(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#decreased_by' do
    it '負の減少量 -1 で ArgumentError を投げること' do
      expect { stress.decreased_by(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#stressed?' do
    context 'level がしきい値の 60 のとき' do
      let(:level) { 60 }

      it 'true を返すこと' do
        expect(stress).to be_stressed
      end
    end

    context 'level がしきい値未満の 59 のとき' do
      let(:level) { 59 }

      it 'false を返すこと' do
        expect(stress).not_to be_stressed
      end
    end
  end

  describe '#severe?' do
    context 'level がしきい値の 90 のとき' do
      let(:level) { 90 }

      it 'true を返すこと' do
        expect(stress).to be_severe
      end
    end

    context 'level がしきい値未満の 89 のとき' do
      let(:level) { 89 }

      it 'false を返すこと' do
        expect(stress).not_to be_severe
      end
    end
  end

  describe '#==' do
    it 'Stress(40) と Stress(40) は等価であること' do
      expect(stress).to eq(described_class.new(40))
    end
  end

  describe '#<=>' do
    it 'Stress(40) は Stress(30) より大きいこと' do
      expect(stress).to be > described_class.new(30)
    end
  end

  describe '#to_s' do
    it '"40/100" を返すこと' do
      expect(stress.to_s).to eq('40/100')
    end
  end
end
