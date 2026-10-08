# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Animal::Pregnancy do
  subject(:pregnancy) { described_class.new(dam: build(:animal, :female), gestation_days:, inbreeding_coefficient: 0.5) }

  let(:gestation_days) { 0 }

  describe '.new' do
    context 'sex を省略したとき' do
      it '性別が決まっていること' do
        expect(pregnancy.sex).to be_a(Animal::Sex)
      end
    end
  end

  describe '#valid?' do
    context '妊娠日数が 0 のとき' do
      it 'true を返すこと' do
        expect(pregnancy).to be_valid
      end
    end

    context '妊娠日数が -1 のとき' do
      let(:gestation_days) { -1 }

      it 'false を返すこと' do
        expect(pregnancy).not_to be_valid
      end
    end

    context '妊娠日数が整数でない 1.5 のとき' do
      let(:gestation_days) { 1.5 }

      it 'false を返すこと' do
        expect(pregnancy).not_to be_valid
      end
    end
  end

  describe '#ongoing?' do
    context '受胎したばかりのとき' do
      it 'true を返すこと' do
        expect(pregnancy).to be_ongoing
      end
    end

    context 'deliver したとき' do
      before { pregnancy.deliver }

      it 'false を返すこと' do
        expect(pregnancy).not_to be_ongoing
      end
    end
  end

  describe '#advance' do
    context '10 を渡したとき' do
      it 'self を返し、妊娠10日になり、近交係数 0.5 は変わらないこと' do
        expect(pregnancy.advance(10)).to be(pregnancy)
        expect(pregnancy).to have_attributes(gestation_days: 10, inbreeding_coefficient: 0.5)
      end
    end

    context '-1 を渡したとき' do
      it 'ArgumentError が発生すること' do
        expect { pregnancy.advance(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#deliver' do
    it 'self を返し、delivered? が true になること' do
      expect(pregnancy.deliver).to be(pregnancy)
      expect(pregnancy).to be_delivered
    end
  end

  describe '#miscarry' do
    it 'self を返し、miscarried? が true になること' do
      expect(pregnancy.miscarry).to be(pregnancy)
      expect(pregnancy).to be_miscarried
    end
  end

  describe '#to_s' do
    let(:gestation_days) { 42 }

    it '"妊娠42日" を返すこと' do
      expect(pregnancy.to_s).to eq('妊娠42日')
    end
  end
end
