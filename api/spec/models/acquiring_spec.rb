# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Acquiring do
  subject(:acquiring) { described_class.new(zoo:, animal:) }

  let(:zoo) { build(:zoo, funds: Money.yen(100_000)) }

  describe '#perform' do
    context '取引可能な種(ニホンザル)のとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.japanese_macaque) }

      it '取得価格ぶん購入し、残高を ¥100,000 から取得価格だけ減らすこと' do
        acquiring.perform

        expect(zoo.balance).to eq(Balance.new(100_000 - animal.acquisition_price.yen))
      end
    end

    context '絶滅危惧種(ライオン=VU)のとき' do
      let(:animal) { build(:animal) }

      it '購入せず残高を ¥100,000 のままにし、保全貢献として評判を上げること' do
        expect { acquiring.perform }.to change(zoo, :reputation).to(be > zoo.reputation)
        expect(zoo.balance).to eq(Balance.new(100_000))
      end
    end

    context '残高が取得価格に足りないとき' do
      let(:zoo) { build(:zoo, funds: Money.zero) }
      let(:animal) { build(:animal, species: SpeciesCatalog.japanese_macaque) }

      it 'InsufficientFunds を投げ、動物を保存しないこと' do
        expect { acquiring.perform }.to raise_error(Errors::InsufficientFunds)
        expect(animal).to be_new_record
      end
    end

    context '購入できたとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.japanese_macaque) }

      it '園と動物を保存し、その園の動物として返すこと' do
        expect(acquiring.perform).to eq(animal)
        expect(zoo).to be_persisted
        expect(animal).to be_persisted.and have_attributes(zoo:)
      end
    end
  end
end
