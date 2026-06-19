# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::Pregnancy do
  sire_id = Zoo::Domain::Shared::Identifier.new

  describe '.conceived' do
    it 'sire_id を父とする妊娠0日のインスタンスを返すこと' do
      pregnancy = described_class.conceived(sire_id)
      expect(pregnancy.sire_id).to eq(sire_id)
      expect(pregnancy.gestation_days).to eq(0)
    end
  end

  describe '#initialize' do
    it 'sire_id が nil なら ArgumentError になること' do
      expect { described_class.new(sire_id: nil, gestation_days: 0) }.to raise_error(ArgumentError)
    end

    it '妊娠日数が負なら ArgumentError になること' do
      expect { described_class.new(sire_id: sire_id, gestation_days: -1) }.to raise_error(ArgumentError)
    end

    it '妊娠日数が整数でなければ ArgumentError になること' do
      expect { described_class.new(sire_id: sire_id, gestation_days: 1.5) }.to raise_error(ArgumentError)
    end
  end

  describe '#advanced_by' do
    it '日数を加算した新しいインスタンスを返すこと(10日経過で 0→10)' do
      advanced = described_class.conceived(sire_id).advanced_by(10)
      expect(advanced.gestation_days).to eq(10)
    end

    it '元のインスタンスを変更しないこと(不変)' do
      pregnancy = described_class.conceived(sire_id)
      pregnancy.advanced_by(10)
      expect(pregnancy.gestation_days).to eq(0)
    end

    it '父個体は引き継がれること' do
      expect(described_class.conceived(sire_id).advanced_by(5).sire_id).to eq(sire_id)
    end

    it '負の日数は ArgumentError になること' do
      expect { described_class.conceived(sire_id).advanced_by(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '等価性' do
    it '同じ父・同じ日数どうしは等価であること' do
      expect(described_class.new(sire_id: sire_id, gestation_days: 30))
        .to eq(described_class.new(sire_id: sire_id, gestation_days: 30))
    end

    it '日数が異なれば等価でないこと' do
      expect(described_class.new(sire_id: sire_id, gestation_days: 30))
        .not_to eq(described_class.new(sire_id: sire_id, gestation_days: 31))
    end
  end

  describe '#to_s' do
    it '"妊娠N日" の形で表されること' do
      expect(described_class.new(sire_id: sire_id, gestation_days: 42).to_s).to eq('妊娠42日')
    end
  end
end
