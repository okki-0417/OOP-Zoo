# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::Pregnancy do
  subject(:pregnancy) { described_class.new(sex:, gestation_days:, inbreeding_coefficient:) }

  let(:sex) { Animal::Sex.male }
  let(:gestation_days) { 0 }
  let(:inbreeding_coefficient) { 0.5 }

  describe '.conceived' do
    it '妊娠0日で、性別が決まり、渡した inbreeding: 0.25 を近交係数に持つこと' do
      expect(described_class.conceived(inbreeding: 0.25))
        .to have_attributes(gestation_days: 0, sex: be_present, inbreeding_coefficient: 0.25)
    end
  end

  describe '.new' do
    context '妊娠日数が -1 のとき' do
      let(:gestation_days) { -1 }

      it 'ArgumentError が発生すること' do
        expect { pregnancy }.to raise_error(ArgumentError)
      end
    end

    context '妊娠日数が整数でない 1.5 のとき' do
      let(:gestation_days) { 1.5 }

      it 'ArgumentError が発生すること' do
        expect { pregnancy }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#advanced_by' do
    context '10 を渡したとき' do
      it '妊娠10日の新しいインスタンスを返し、元は妊娠0日のままであること' do
        expect(pregnancy.advanced_by(10).gestation_days).to eq(10)
        expect(pregnancy.gestation_days).to eq(0)
      end

      it '性別(オス)と近交係数 0.5 を引き継ぐこと' do
        expect(pregnancy.advanced_by(10)).to have_attributes(sex:, inbreeding_coefficient: 0.5)
      end
    end

    context '-1 を渡したとき' do
      it 'ArgumentError が発生すること' do
        expect { pregnancy.advanced_by(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#==' do
    let(:gestation_days) { 30 }

    context '性別・日数・近交係数が同じとき' do
      it '等しいこと' do
        expect(pregnancy).to eq(described_class.new(sex:, gestation_days: 30, inbreeding_coefficient: 0.5))
      end
    end

    context '日数が 30 と 31 で違うとき' do
      it '等しくないこと' do
        expect(pregnancy).not_to eq(described_class.new(sex:, gestation_days: 31, inbreeding_coefficient: 0.5))
      end
    end
  end

  describe '#to_s' do
    let(:gestation_days) { 42 }

    it '"妊娠42日" を返すこと' do
      expect(pregnancy.to_s).to eq('妊娠42日')
    end
  end
end
