# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::Illness do
  describe '.new' do
    it "name_ja='風邪'、daily_damage=2 で生成できること" do
      illness = described_class.new(name_ja: '風邪', daily_damage: 2)
      expect(illness.name_ja).to eq('風邪')
      expect(illness.daily_damage).to eq(2)
    end

    it 'contagious を省略すると非感染症として扱われること' do
      expect(described_class.new(name_ja: '骨折', daily_damage: 4)).not_to be_contagious
    end

    it 'name_ja が空文字だと ArgumentError が発生すること' do
      expect { described_class.new(name_ja: '', daily_damage: 1) }.to raise_error(ArgumentError)
    end

    it 'daily_damage=0 だと ArgumentError が発生すること' do
      expect { described_class.new(name_ja: '風邪', daily_damage: 0) }.to raise_error(ArgumentError)
    end

    it 'daily_damage が Integer 以外だと ArgumentError が発生すること' do
      expect { described_class.new(name_ja: '風邪', daily_damage: 1.5) }.to raise_error(ArgumentError)
    end
  end

  describe '#contagious?' do
    it 'contagious: true で生成すると true を返すこと' do
      expect(described_class.new(name_ja: '風邪', daily_damage: 2, contagious: true)).to be_contagious
    end

    it 'contagious: false で生成すると false を返すこと' do
      expect(described_class.new(name_ja: '骨折', daily_damage: 4, contagious: false)).not_to be_contagious
    end
  end

  describe '#severe?' do
    it 'daily_damage=5 だと true を返すこと(閾値ぴったり)' do
      expect(described_class.new(name_ja: '重症', daily_damage: 5)).to be_severe
    end

    it 'daily_damage=4 だと false を返すこと' do
      expect(described_class.new(name_ja: '骨折', daily_damage: 4)).not_to be_severe
    end
  end

  describe '#to_s' do
    it 'name_ja をそのまま返すこと' do
      expect(described_class.new(name_ja: '風邪', daily_damage: 2).to_s).to eq('風邪')
    end
  end

  describe '等価性' do
    it 'name_ja・daily_damage・contagious が全て同じなら eq で等しいこと' do
      a = described_class.new(name_ja: '風邪', daily_damage: 2, contagious: true)
      b = described_class.new(name_ja: '風邪', daily_damage: 2, contagious: true)
      expect(a).to eq(b)
    end

    it 'daily_damage が違うと eq で等しくないこと' do
      a = described_class.new(name_ja: '風邪', daily_damage: 2)
      b = described_class.new(name_ja: '風邪', daily_damage: 3)
      expect(a).not_to eq(b)
    end
  end
end

RSpec.describe Zoo::Domain::IllnessCatalog do
  it '.all は KEYS と同数の疾病を返し、各疾病を含むこと' do
    expect(described_class.all.size).to eq(described_class.keys.size)
    expect(described_class.all).to include(described_class.cold)
  end

  it '.find は未知のキーに nil を返すこと' do
    expect(described_class.find(:unknown)).to be_nil
  end
end
