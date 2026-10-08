# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Acquiring do
  subject(:acquiring) { described_class.new(zoo:, animal:) }

  let(:zoo) { create(:zoo, opening_funds: Money.yen(100_000)) }

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

      it '費用 ¥0 で記録し、残高を ¥100,000 のままにすること' do
        acquiring.perform

        expect(acquiring.cost).to eq(Money.zero)
        expect(zoo.balance).to eq(Balance.new(100_000))
      end

      it '受け入れた時点では評判を変えないこと' do
        expect { acquiring.perform }.not_to change(zoo, :reputation)
      end
    end

    context '残高が取得価格に足りないとき' do
      let(:zoo) { create(:zoo, opening_funds: Money.zero) }
      let(:animal) { build(:animal, species: SpeciesCatalog.japanese_macaque) }

      it 'InsufficientFunds を投げ、動物を保存しないこと' do
        expect { acquiring.perform }.to raise_error(Errors::InsufficientFunds)
        expect(animal).to be_new_record
      end
    end

    context '購入できたとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.japanese_macaque) }

      it '0日目・取得価格の記録として保存されること' do
        acquiring.perform

        expect(acquiring).to be_persisted.and have_attributes(day: 0, cost: animal.acquisition_price)
      end

      it '動物を保存し、その園の動物として返すこと' do
        expect(acquiring.perform).to eq(animal)
        expect(animal).to be_persisted.and have_attributes(zoo:)
      end
    end
  end

  describe '#conservation?' do
    context '絶滅危惧種(ライオン=VU)のとき' do
      let(:animal) { build(:animal) }

      it 'true を返すこと' do
        expect(acquiring).to be_conservation
      end
    end

    context '取引可能な種(ニホンザル)のとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.japanese_macaque) }

      it 'false を返すこと' do
        expect(acquiring).not_to be_conservation
      end
    end
  end
end
