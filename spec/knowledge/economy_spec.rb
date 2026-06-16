# frozen_string_literal: true

require 'spec_helper'

# 動物園は資金を制約に運営される。動物の取得・エリアの建設・職員の雇用には費用がかかり、
# 残高で支払えなければ実行できない。一方、日々の運営費は避けられず、残高を超えても支払われ
# 赤字(破産)になりうる。この「裁量的な購入」と「不可避の支出」の違いが経済の知識である。
#
# 用語（経済ドメイン共通。ブレたらここに合わせる。他の経済 knowledge spec はここを参照）:
#   集客 = f(魅力, 評判, 料金) … その日の来園者数(フロー)
#   評判 … 運営の質・信用(ストック)。来た人の体験へドリフト(露出=来場規模で重み付け)し、死亡・疫病
#           など顕著なイベントで動く。非対称(築くは遅く失うは速い)、放置で中立へ自然減衰。
#   魅力 … 展示の引き「何が見られるか」。種カリスマ＋話題(buzz=幼獣/新展示/イベント)。
#           種数(多様性)そのものは引きにならない(カリスマ合計に内包)。
#   料金 … 入園料(需要レバー、弾力性)
#
# 区別（混同しない）:
#   - 福祉・死亡・スキャンダル・保全・清潔・過密 → 評判 を上下させる(集客に直接は効かせない＝二重計上回避)
#   - 種カリスマ・話題 → 魅力(評判とは別軸)
#   - 年齢・健康・血統 → 個体の資産/繁殖価値(集客ではない。繁殖・売却・コストに効く)
RSpec.describe '運営の経済' do
  money   = Zoo::Domain::Shared::Money
  balance = Zoo::Domain::Shared::Balance
  pricing = Zoo::Domain::Operations::Pricing
  errors  = Zoo::Domain::Errors
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog

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
