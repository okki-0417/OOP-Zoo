# frozen_string_literal: true

require 'spec_helper'

# 個体の入手経路の知識。現代の動物園では、絶滅危惧種は商業的に売買せず、種の保存計画
# (SSP/EEP等)を通じて園館間で移送・貸与される(CITES附属書I)。一般的な種は取引で入手しうる。
# (※受け入れ時の課金/無償・保全評判の振る舞いは spec/zoo/application の AcquireAnimal を参照)
RSpec.describe '個体の入手経路' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  pricing = Zoo::Domain::Operations::Pricing

  describe '取引で入手できる種' do
    it '保全上の懸念が低い一般的な種(ニホンザル=低危険)は取引可能であること' do
      expect(catalog.japanese_macaque.tradeable?).to be(true)
      expect(catalog.koi.tradeable?).to be(true)
    end

    it '購入価格は体格に応じて定まること(取引可能な種どうしで体格の大きい方が高い)' do
      expect(pricing.acquisition_price(catalog.japanese_macaque)) # 11kg
        .to be > pricing.acquisition_price(catalog.koi)           # 5kg
    end
  end

  describe '絶滅危惧種' do
    it '絶滅危惧種(ライオン=VU、アフリカゾウ=EN)は取引できないこと' do
      expect(catalog.lion.tradeable?).to be(false)
      expect(catalog.african_elephant.tradeable?).to be(false)
    end

    it '絶滅危惧種を受け入れ展示することは保全への貢献になること' do
      expect(catalog.lion.conservation_status.threatened?).to be(true)
    end
  end
end
