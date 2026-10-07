# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Enclosure::Cleanliness do
  subject(:cleanliness) { described_class.new(level) }

  let(:level) { 50 }

  describe '.new' do
    context '50 を渡したとき' do
      it 'level が 50 になること' do
        expect(cleanliness.level).to eq(50)
      end
    end

    context 'MAX(100)を超える 999 を渡したとき' do
      let(:level) { 999 }

      it 'level が MAX(100) に丸められること' do
        expect(cleanliness.level).to eq(described_class::MAX)
      end
    end

    context 'MIN(0)未満の -50 を渡したとき' do
      let(:level) { -50 }

      it 'level が MIN(0) に丸められること' do
        expect(cleanliness.level).to eq(described_class::MIN)
      end
    end

    context 'Integer でない 1.5 を渡したとき' do
      let(:level) { 1.5 }

      it 'ArgumentError を投げること' do
        expect { cleanliness }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.spotless' do
    it 'level=MAX(100) の Cleanliness を返すこと' do
      expect(described_class.spotless.level).to eq(described_class::MAX)
    end
  end

  describe '#soiled_by' do
    let(:level) { 100 }

    context 'level=100 に 30 を渡したとき' do
      it 'level=70 の Cleanliness を返し、元の Cleanliness は level=100 のままであること' do
        expect(cleanliness.soiled_by(30).level).to eq(70)
        expect(cleanliness.level).to eq(described_class::MAX)
      end
    end

    context 'level=10 に 50 を渡したとき' do
      let(:level) { 10 }

      it 'level が MIN(0) に丸められること' do
        expect(cleanliness.soiled_by(50).level).to eq(0)
      end
    end

    context '-1 を渡したとき' do
      it 'ArgumentError を投げること' do
        expect { cleanliness.soiled_by(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#cleaned_by' do
    context 'level=50 に 30 を渡したとき' do
      it 'level=80 の Cleanliness を返すこと' do
        expect(cleanliness.cleaned_by(30).level).to eq(80)
      end
    end

    context 'level=80 に 50 を渡したとき' do
      let(:level) { 80 }

      it 'level が MAX(100) に丸められること' do
        expect(cleanliness.cleaned_by(50).level).to eq(described_class::MAX)
      end
    end

    context '-1 を渡したとき' do
      it 'ArgumentError を投げること' do
        expect { cleanliness.cleaned_by(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#filthy?' do
    context 'level が FILTHY_THRESHOLD(30)のとき' do
      let(:level) { described_class::FILTHY_THRESHOLD }

      it 'true を返すこと' do
        expect(cleanliness).to be_filthy
      end
    end

    context 'level が FILTHY_THRESHOLD + 1(31)のとき' do
      let(:level) { described_class::FILTHY_THRESHOLD + 1 }

      it 'false を返すこと' do
        expect(cleanliness).not_to be_filthy
      end
    end
  end

  describe '#soiled?' do
    context 'level が SOILED_THRESHOLD(70)のとき' do
      let(:level) { described_class::SOILED_THRESHOLD }

      it 'true を返すこと' do
        expect(cleanliness).to be_soiled
      end
    end

    context 'level が SOILED_THRESHOLD + 1(71)のとき' do
      let(:level) { described_class::SOILED_THRESHOLD + 1 }

      it 'false を返すこと' do
        expect(cleanliness).not_to be_soiled
      end
    end
  end

  describe '#<=>' do
    it 'level=10 の Cleanliness は level=20 の Cleanliness より小さいこと' do
      expect(described_class.new(10)).to be < described_class.new(20)
    end
  end

  describe '#==' do
    it 'level=50 同士の Cleanliness は等しいこと' do
      expect(described_class.new(50)).to eq(described_class.new(50))
    end
  end
end
