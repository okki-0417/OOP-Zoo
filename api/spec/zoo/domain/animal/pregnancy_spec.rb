# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::Pregnancy do
  sex = Zoo::Domain::Animal::Sex.male

  describe '.conceived' do
    it '妊娠0日のインスタンスを返すこと' do
      pregnancy = described_class.conceived
      expect(pregnancy.gestation_days).to eq(0)
    end

    it '受胎時に sex と inbreeding_coefficient が設定されること' do
      pregnancy = described_class.conceived(inbreeding: 0.25)
      expect(pregnancy.sex).not_to be_nil
      expect(pregnancy.inbreeding_coefficient).to eq(0.25)
    end
  end

  describe '#initialize' do
    it '妊娠日数が負なら ArgumentError になること' do
      expect { described_class.new(sex: sex, gestation_days: -1) }.to raise_error(ArgumentError)
    end

    it '妊娠日数が整数でなければ ArgumentError になること' do
      expect { described_class.new(sex: sex, gestation_days: 1.5) }.to raise_error(ArgumentError)
    end
  end

  describe '#advanced_by' do
    it '日数を加算した新しいインスタンスを返すこと(10日経過で 0→10)' do
      advanced = described_class.conceived.advanced_by(10)
      expect(advanced.gestation_days).to eq(10)
    end

    it '元のインスタンスを変更しないこと(不変)' do
      pregnancy = described_class.conceived
      pregnancy.advanced_by(10)
      expect(pregnancy.gestation_days).to eq(0)
    end

    it '性別と近交係数は引き継がれること' do
      pregnancy = described_class.new(sex: sex, gestation_days: 0, inbreeding_coefficient: 0.5)
      advanced = pregnancy.advanced_by(5)
      expect(advanced.sex).to eq(sex)
      expect(advanced.inbreeding_coefficient).to eq(0.5)
    end

    it '負の日数は ArgumentError になること' do
      expect { described_class.conceived.advanced_by(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '等価性' do
    it '同じ性別・日数・近交係数どうしは等価であること' do
      expect(described_class.new(sex: sex, gestation_days: 30))
        .to eq(described_class.new(sex: sex, gestation_days: 30))
    end

    it '日数が異なれば等価でないこと' do
      expect(described_class.new(sex: sex, gestation_days: 30))
        .not_to eq(described_class.new(sex: sex, gestation_days: 31))
    end
  end

  describe '#to_s' do
    it '"妊娠N日" の形で表されること' do
      expect(described_class.new(sex: sex, gestation_days: 42).to_s).to eq('妊娠42日')
    end
  end
end
