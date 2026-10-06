# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Keeper::Shift do
  describe '.fresh' do
    it 'worked_minutes=0・remaining_minutes=480 を返すこと' do
      expect(described_class.fresh).to have_attributes(worked_minutes: 0, remaining_minutes: 480)
    end
  end

  describe '.new' do
    it '-1 や 481 や 1.5 を渡すと ArgumentError になること' do
      [-1, 481, 1.5].each { |minutes| expect { described_class.new(minutes) }.to raise_error(ArgumentError) }
    end
  end

  describe '#allows?' do
    it '残り30分のとき allows?(30) は true、allows?(31) は false であること' do
      shift = described_class.new(450)
      expect(shift.allows?(30)).to be(true)
      expect(shift.allows?(31)).to be(false)
    end
  end

  describe '#worked' do
    it 'worked_minutes=100 に worked(60) すると 160 の新しい Shift を返し、元は変わらないこと' do
      shift = described_class.new(100)
      expect(shift.worked(60).worked_minutes).to eq(160)
      expect(shift.worked_minutes).to eq(100)
    end

    it '-1 を渡すと ArgumentError になること' do
      expect { described_class.fresh.worked(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#to_s / #==' do
    it 'to_s は "100/480分" を返し、同じ勤務時間なら等価であること' do
      expect(described_class.new(100).to_s).to eq('100/480分')
      expect(described_class.new(100)).to eq(described_class.new(100))
    end
  end
end
