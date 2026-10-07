# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Acquiring do
  subject(:acquiring) { described_class.new(zoo:, animal:) }

  let(:zoo) { build(:zoo, funds: Money.yen(100_000)) }

  describe '#settle' do
    context '取引可能な種(ニホンザル)のとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.japanese_macaque) }

      it '取得価格ぶん購入し、残高を ¥100,000 から取得価格だけ減らすこと' do
        acquiring.settle

        expect(zoo.balance).to eq(Balance.new(100_000 - animal.acquisition_price.yen))
      end
    end

    context '絶滅危惧種(ライオン=VU)のとき' do
      let(:animal) { build(:animal) }

      it '購入せず残高を ¥100,000 のままにし、保全貢献として評判を上げること' do
        expect { acquiring.settle }.to change(zoo, :reputation).to(be > zoo.reputation)
        expect(zoo.balance).to eq(Balance.new(100_000))
      end
    end
  end
end
