# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Zoo do
  let(:zoo) { create(:zoo, funds: Money.yen(100_000), admission_fee: Money.yen(2_000)) }

  describe 'balance' do
    it '残高 ¥100,000 を円の整数 100000 で返すこと' do
      expect(run_graphql_field('Zoo.balance', zoo)).to eq(100_000)
    end
  end

  describe 'admissionFee' do
    it '入園料 ¥2,000 を円の整数 2000 で返すこと' do
      expect(run_graphql_field('Zoo.admissionFee', zoo)).to eq(2_000)
    end
  end

  describe 'reputation' do
    it '評判の表示値 50 を返すこと' do
      expect(run_graphql_field('Zoo.reputation', zoo)).to eq(50)
    end
  end

  describe 'reputationSwingLimit' do
    it '6 を返すこと' do
      expect(run_graphql_field('Zoo.reputationSwingLimit', zoo)).to eq(6)
    end
  end

  describe 'visitorsForFullSwing' do
    it '2000 を返すこと' do
      expect(run_graphql_field('Zoo.visitorsForFullSwing', zoo)).to eq(2_000)
    end
  end

  describe 'spectacleSaturation' do
    it '3000 を返すこと' do
      expect(run_graphql_field('Zoo.spectacleSaturation', zoo)).to eq(3_000)
    end
  end

  context 'ライオンの丘にライオン1頭を展示しているとき' do
    before { create(:animal, enclosure: create(:enclosure, name: 'ライオンの丘')) }

    describe 'exhibitCondition' do
      it '100 を返すこと' do
        expect(run_graphql_field('Zoo.exhibitCondition', zoo)).to eq(100)
      end
    end

    describe 'experience' do
      it '96 を返すこと' do
        expect(run_graphql_field('Zoo.experience', zoo)).to eq(96)
      end
    end

    describe 'expectedVisitors' do
      it '19 を返すこと' do
        expect(run_graphql_field('Zoo.expectedVisitors', zoo)).to eq(19)
      end
    end

    describe 'spectacle' do
      it '87 を返すこと' do
        expect(run_graphql_field('Zoo.spectacle', zoo)).to eq(87)
      end
    end

    describe 'willingnessToPay' do
      it '3655 を返すこと' do
        expect(run_graphql_field('Zoo.willingnessToPay', zoo)).to eq(3_655)
      end
    end

    describe 'reputationDecay' do
      it '露出0では下がらないので 0.0 を返すこと' do
        expect(run_graphql_field('Zoo.reputationDecay', zoo)).to eq(0.0)
      end
    end

    describe 'reputationDrift' do
      it '約 +0.028 を返すこと' do
        expect(run_graphql_field('Zoo.reputationDrift', zoo)).to be_within(0.001).of(0.028)
      end
    end
  end
end
