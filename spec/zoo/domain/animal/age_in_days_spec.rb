# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::AgeInDays do
  let(:lion) { Zoo::Domain::SpeciesCatalog.lion }

  describe '.new' do
    it '0 を渡すと value が 0 を返すこと' do
      expect(described_class.new(0).value).to eq(0)
    end

    it '-1 を渡すと ArgumentError が発生すること' do
      expect { described_class.new(-1) }.to raise_error(ArgumentError)
    end

    it 'Integer 以外(例: 1.5)を渡すと ArgumentError が発生すること' do
      expect { described_class.new(1.5) }.to raise_error(ArgumentError)
    end
  end

  describe '.zero' do
    it '.new(0) と等しい AgeInDays を返すこと' do
      expect(described_class.zero).to eq(described_class.new(0))
    end
  end

  describe '#advanced_by' do
    it 'AgeInDays.new(10).advanced_by(5) の value は 15 を返すこと' do
      expect(described_class.new(10).advanced_by(5).value).to eq(15)
    end

    it '元のインスタンスは不変であること(value は変わらない)' do
      age = described_class.new(10)
      age.advanced_by(5)
      expect(age.value).to eq(10)
    end

    it '0 を渡すと ArgumentError が発生すること' do
      expect { described_class.new(10).advanced_by(0) }.to raise_error(ArgumentError)
    end

    it '-1 を渡すと ArgumentError が発生すること' do
      expect { described_class.new(10).advanced_by(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#years' do
    it 'age_in_days=365*2+10 のとき 2 を返すこと(端数切り捨て)' do
      expect(described_class.new((365 * 2) + 10).years).to eq(2)
    end

    it 'age_in_days=0 のとき 0 を返すこと' do
      expect(described_class.zero.years).to eq(0)
    end
  end

  describe '#life_stage(species)' do
    it 'age=0 のライオンは幼体(baby)を返すこと' do
      expect(described_class.zero.life_stage(lion)).to be_baby
    end

    it 'age=365*3(性成熟)のライオンは成体(adult)を返すこと' do
      expect(described_class.new(365 * 3).life_stage(lion)).to be_adult
    end

    it 'age=365*13(寿命の80%超)のライオンは老齢(elderly)を返すこと' do
      expect(described_class.new(365 * 13).life_stage(lion)).to be_elderly
    end
  end

  describe '#mature?(species)' do
    it 'age=365*3 のライオンは true を返すこと' do
      expect(described_class.new(365 * 3).mature?(lion)).to be(true)
    end

    it 'age=0 のライオンは false を返すこと' do
      expect(described_class.zero.mature?(lion)).to be(false)
    end
  end

  describe '#past_lifespan?(species)' do
    it 'age=365*16 のライオン(寿命15年)は true を返すこと' do
      expect(described_class.new(365 * 16).past_lifespan?(lion)).to be(true)
    end

    it 'age=365*15 のライオン(寿命と同年齢)は false を返すこと' do
      expect(described_class.new(365 * 15).past_lifespan?(lion)).to be(false)
    end
  end

  describe '#past_breeding_age?(species)' do
    it 'age=365*12 のライオン(寿命15年の8割ちょうど)は true を返すこと' do
      expect(described_class.new(365 * 12).past_breeding_age?(lion)).to be(true)
    end

    it 'age=365*11 のライオン(8割未満)は false を返すこと' do
      expect(described_class.new(365 * 11).past_breeding_age?(lion)).to be(false)
    end
  end

  describe '#weaned?(species)' do
    it 'age=219 のライオン(離乳適齢ちょうど)は true を返すこと' do
      expect(described_class.new(219).weaned?(lion)).to be(true)
    end

    it 'age=218 のライオン(離乳適齢未満)は false を返すこと' do
      expect(described_class.new(218).weaned?(lion)).to be(false)
    end
  end

  describe '大小比較(Comparable)' do
    it 'value の大小で比較されること' do
      expect(described_class.new(10)).to be < described_class.new(20)
      expect(described_class.new(20)).to be > described_class.new(10)
    end
  end

  describe '等価性' do
    it '同じ value 同士は eq で等しいこと' do
      expect(described_class.new(10)).to eq(described_class.new(10))
    end
  end
end
