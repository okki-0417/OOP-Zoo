# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Relieving do
  subject(:relieving) { described_class.new(keeper:, enclosure:) }

  let(:keeper) { build(:keeper, name: '田中') }
  let(:enclosure) { build(:enclosure, name: 'サバンナ') }

  describe '.new' do
    it 'frozen であること' do
      expect(relieving).to be_frozen
    end
  end

  describe '#violation!' do
    context '田中がサバンナを担当しているとき' do
      before { keeper.enclosures << enclosure }

      it '例外を投げないこと' do
        expect { relieving.violation! }.not_to raise_error
      end
    end

    context '田中がサバンナを担当していないとき' do
      it 'ReliefNotAllowed(田中…サバンナ…退任) を投げること' do
        expect { relieving.violation! }.to raise_error(Errors::ReliefNotAllowed, /田中.*サバンナ.*退任/)
      end
    end
  end

  describe '#perform' do
    context '田中がサバンナを担当しているとき' do
      before { keeper.enclosures << enclosure }

      it '田中の担当からサバンナを外し、in_charge_of?(サバンナ) を false にすること' do
        relieving.perform

        expect(keeper.in_charge_of?(enclosure)).to be(false)
      end
    end

    context '田中とサバンナの担当が保存済みのとき' do
      let(:keeper) { create(:keeper, name: '田中') }
      let(:enclosure) { create(:enclosure, name: 'サバンナ') }

      before { keeper.enclosures << enclosure }

      it 'assignments の行を1から0に減らすこと' do
        expect { relieving.perform }.to change(Assignment, :count).from(1).to(0)
      end
    end

    context '田中がサバンナを担当していないとき' do
      it 'ReliefNotAllowed を投げること' do
        expect { relieving.perform }.to raise_error(Errors::ReliefNotAllowed)
      end
    end
  end

  describe '#to_s' do
    it '"田中をサバンナの担当から外す" を返すこと' do
      expect(relieving.to_s).to eq('田中をサバンナの担当から外す')
    end
  end
end
