# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '運営の経済' do
  money   = Zoo::Domain::Shared::Money
  balance = Zoo::Domain::Shared::Balance
  pricing = Zoo::Domain::Pricing
  errors  = Zoo::Domain::Errors
  catalog = Zoo::Domain::SpeciesCatalog

  def zoo(funds:)
    Zoo::Domain::Zoo.new(
      name: '動物園', admission_fee: Zoo::Domain::Shared::Money.yen(2_000),
      funds: Zoo::Domain::Shared::Money.yen(funds)
    )
  end

  describe '成長アクションの費用' do
    context '動物を取得するとき' do
      it '希少な種ほど高くつくこと(絶滅危惧のキリン > 低危険のニホンザル)' do
        expect(pricing.acquisition_price(catalog.reticulated_giraffe))
          .to be > pricing.acquisition_price(catalog.japanese_macaque)
      end

      it '体格が大きい種ほど高くつくこと(ゾウ > サル)' do
        expect(pricing.acquisition_price(catalog.african_elephant))
          .to be > pricing.acquisition_price(catalog.japanese_macaque)
      end
    end

    context 'エリアを建設するとき' do
      it '定員が大きいほど建設費が高くなること' do
        expect(pricing.enclosure_construction_cost(capacity: 10))
          .to be > pricing.enclosure_construction_cost(capacity: 3)
      end
    end

    context '職員を雇うとき' do
      it '採用に一時金がかかり、獣医は飼育員より高くつくこと' do
        expect(pricing.veterinarian_signing_fee).to be > pricing.keeper_signing_fee
      end
    end
  end

  describe '資金の制約' do
    context '残高で支払えるとき' do
      it '購入するとその費用ぶん残高が減ること' do
        z = zoo(funds: 100_000)
        z.purchase(money.yen(30_000))
        expect(z.balance).to eq(balance.new(70_000))
      end
    end

    context '残高が費用に満たないとき' do
      it '資金不足として購入できないこと' do
        expect { zoo(funds: 10_000).purchase(money.yen(30_000)) }
          .to raise_error(errors::InsufficientFunds)
      end

      it '購入が拒否されたとき残高は変わらないこと' do
        z = zoo(funds: 10_000)
        expect { z.purchase(money.yen(30_000)) }.to raise_error(errors::InsufficientFunds)
        expect(z.balance).to eq(balance.new(10_000))
      end
    end

    context '避けられない運営費を支払うとき' do
      it '残高を超えても支払われ、赤字(破産)になりうること(購入との違い)' do
        z = zoo(funds: 1_000)
        z.spend(money.yen(5_000))
        expect(z).to be_bankrupt
      end
    end
  end
end
