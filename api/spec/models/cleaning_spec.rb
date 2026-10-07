# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cleaning do
  subject(:cleaning) { described_class.new(keeper:, enclosure:) }

  let(:keeper) { build(:keeper, name: '田中') }
  let(:enclosure) { build(:enclosure, name: 'サバンナ') }

  describe '.new' do
    it '渡した keeper・enclosure を #keeper・#enclosure で返すこと' do
      expect(cleaning).to have_attributes(keeper:, enclosure:)
    end

    it 'frozen であること' do
      expect(cleaning).to be_frozen
    end
  end

  describe '#perform' do
    context 'amount を省略したとき' do
      before { enclosure.soil(40) }

      it '清潔度 60 のエリアを 100 に戻し、田中の勤務時間を 60 分使うこと' do
        cleaning.perform

        expect(enclosure.cleanliness.level).to eq(100)
        expect(keeper.worked_minutes).to eq(60)
      end
    end

    context 'amount: 30 を渡したとき' do
      subject(:cleaning) { described_class.new(keeper:, enclosure:, amount: 30) }

      before { enclosure.soil(100) }

      it '清潔度 0 のエリアを 30 だけ回復すること' do
        cleaning.perform

        expect(enclosure.cleanliness.level).to eq(30)
      end
    end
  end

  describe '#to_s' do
    it '"田中がサバンナを清掃" を返すこと' do
      expect(cleaning.to_s).to eq('田中がサバンナを清掃')
    end
  end
end
