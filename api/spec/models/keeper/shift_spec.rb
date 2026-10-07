# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Keeper::Shift do
  subject(:shift) { described_class.new(worked_minutes) }

  let(:worked_minutes) { 100 }

  describe '.fresh' do
    it 'worked_minutes=0・remaining_minutes=480 を返すこと' do
      expect(described_class.fresh).to have_attributes(worked_minutes: 0, remaining_minutes: 480)
    end
  end

  describe '.new' do
    context '負の -1 を渡したとき' do
      let(:worked_minutes) { -1 }

      it 'ArgumentError を投げること' do
        expect { shift }.to raise_error(ArgumentError)
      end
    end

    context '上限480を超える 481 を渡したとき' do
      let(:worked_minutes) { 481 }

      it 'ArgumentError を投げること' do
        expect { shift }.to raise_error(ArgumentError)
      end
    end

    context '整数でない 1.5 を渡したとき' do
      let(:worked_minutes) { 1.5 }

      it 'ArgumentError を投げること' do
        expect { shift }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#allows?' do
    let(:worked_minutes) { 450 }

    it '残り30分の Shift は allows?(30) が true、allows?(31) が false であること' do
      expect(shift.allows?(30)).to be(true)
      expect(shift.allows?(31)).to be(false)
    end
  end

  describe '#worked' do
    it 'worked_minutes=100 に worked(60) すると 160 の新しい Shift を返し、元は100のままであること' do
      expect(shift.worked(60).worked_minutes).to eq(160)
      expect(shift.worked_minutes).to eq(100)
    end

    context '負の -1 を渡したとき' do
      it 'ArgumentError を投げること' do
        expect { shift.worked(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#to_s' do
    it '"100/480分" を返すこと' do
      expect(shift.to_s).to eq('100/480分')
    end
  end

  describe '#==' do
    it '同じ worked_minutes=100 の Shift と等しいこと' do
      expect(shift).to eq(described_class.new(100))
    end
  end
end
