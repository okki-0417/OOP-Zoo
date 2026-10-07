# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::Hunger do
  subject(:hunger) { described_class.new(level) }

  let(:level) { 50 }

  describe '.new' do
    context '50 を渡したとき' do
      it 'level が 50 になること' do
        expect(hunger.level).to eq(50)
      end
    end

    context 'MAX(100)を超える 999 を渡したとき' do
      let(:level) { 999 }

      it 'level が MAX(100) に丸められること' do
        expect(hunger.level).to eq(described_class::MAX)
      end
    end

    context 'MIN(0)未満の -50 を渡したとき' do
      let(:level) { -50 }

      it 'level が MIN(0) に丸められること' do
        expect(hunger.level).to eq(described_class::MIN)
      end
    end

    context 'Integer でない 1.5 を渡したとき' do
      let(:level) { 1.5 }

      it 'ArgumentError を投げること' do
        expect { hunger }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.satisfied' do
    subject(:hunger) { described_class.satisfied }

    it 'level=0(MIN)の満腹の Hunger を返すこと' do
      expect(hunger.level).to eq(0)
      expect(hunger).to be_satisfied
    end
  end

  describe '#increased_by' do
    let(:level) { 10 }

    context '20 を渡したとき' do
      it 'level=10 から level=30 の Hunger を返し、元の Hunger は level=10 のままであること' do
        expect(hunger.increased_by(20).level).to eq(30)
        expect(hunger.level).to eq(10)
      end
    end

    context 'level=80 に 50 を渡したとき' do
      let(:level) { 80 }

      it 'level が MAX(100) に丸められること' do
        expect(hunger.increased_by(50).level).to eq(described_class::MAX)
      end
    end

    context '-1 を渡したとき' do
      it 'ArgumentError を投げること' do
        expect { hunger.increased_by(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#decreased_by' do
    context 'level=50 に 20 を渡したとき' do
      it 'level=30 の Hunger を返すこと' do
        expect(hunger.decreased_by(20).level).to eq(30)
      end
    end

    context 'level=10 に 50 を渡したとき' do
      let(:level) { 10 }

      it 'level が MIN(0) に丸められること' do
        expect(hunger.decreased_by(50).level).to eq(0)
      end
    end

    context '-1 を渡したとき' do
      it 'ArgumentError を投げること' do
        expect { hunger.decreased_by(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#hungry?' do
    context 'level が HUNGRY_THRESHOLD(70)のとき' do
      let(:level) { described_class::HUNGRY_THRESHOLD }

      it 'true を返すこと' do
        expect(hunger).to be_hungry
      end
    end

    context 'level が HUNGRY_THRESHOLD - 1(69)のとき' do
      let(:level) { described_class::HUNGRY_THRESHOLD - 1 }

      it 'false を返すこと' do
        expect(hunger).not_to be_hungry
      end
    end
  end

  describe '#starving?' do
    context 'level が MAX(100)のとき' do
      let(:level) { described_class::MAX }

      it 'true を返すこと' do
        expect(hunger).to be_starving
      end
    end

    context 'level が MAX - 1(99)のとき' do
      let(:level) { described_class::MAX - 1 }

      it 'false を返すこと' do
        expect(hunger).not_to be_starving
      end
    end
  end

  describe '#satisfied?' do
    context 'level=0 のとき' do
      let(:level) { 0 }

      it 'true を返すこと' do
        expect(hunger).to be_satisfied
      end
    end

    context 'level=1 のとき' do
      let(:level) { 1 }

      it 'false を返すこと' do
        expect(hunger).not_to be_satisfied
      end
    end
  end

  describe '#<=>' do
    it 'level=10 の Hunger は level=20 の Hunger より小さいこと' do
      expect(described_class.new(10)).to be < described_class.new(20)
    end
  end

  describe '#==' do
    it 'level=10 同士の Hunger は等しいこと' do
      expect(described_class.new(10)).to eq(described_class.new(10))
    end
  end
end
