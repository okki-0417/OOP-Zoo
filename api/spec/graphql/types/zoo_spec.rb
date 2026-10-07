# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Zoo do
  let(:zoo) { create(:zoo, funds: Money.yen(100_000), admission_fee: Money.yen(2_000)) }

  it 'balance・admissionFee は Balance(¥100,000)・Money(¥2,000) を円の整数 100000・2000 で返すこと' do
    expect(run_graphql_field('Zoo.balance', zoo)).to eq(100_000)
    expect(run_graphql_field('Zoo.admissionFee', zoo)).to eq(2_000)
  end

  it 'reputation は評判の表示値 50 を返すこと' do
    expect(run_graphql_field('Zoo.reputation', zoo)).to eq(50)
  end

  context 'ライオンの丘にライオン1頭を展示しているとき' do
    before { create(:animal, enclosure: create(:enclosure, name: 'ライオンの丘')) }

    it 'exhibitCondition=100・experience=96・expectedVisitors=19 を返すこと' do
      expect(run_graphql_field('Zoo.exhibitCondition', zoo)).to eq(100)
      expect(run_graphql_field('Zoo.experience', zoo)).to eq(96)
      expect(run_graphql_field('Zoo.expectedVisitors', zoo)).to eq(19)
    end

    it 'spectacle=87・willingnessToPay=3655 を返すこと' do
      expect(run_graphql_field('Zoo.spectacle', zoo)).to eq(87)
      expect(run_graphql_field('Zoo.willingnessToPay', zoo)).to eq(3_655)
    end

    it 'reputationDecay=0.0(露出0では下がらない)・reputationDrift は約 +0.028 を返すこと' do
      expect(run_graphql_field('Zoo.reputationDecay', zoo)).to eq(0.0)
      expect(run_graphql_field('Zoo.reputationDrift', zoo)).to be_within(0.001).of(0.028)
    end
  end

  it 'reputationSwingLimit=6・visitorsForFullSwing=2000・spectacleSaturation=3000 の定数を返すこと' do
    expect(run_graphql_field('Zoo.reputationSwingLimit', zoo)).to eq(6)
    expect(run_graphql_field('Zoo.visitorsForFullSwing', zoo)).to eq(2_000)
    expect(run_graphql_field('Zoo.spectacleSaturation', zoo)).to eq(3_000)
  end
end
