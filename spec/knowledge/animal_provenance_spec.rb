# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '個体の入手経路' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  pricing = Zoo::Domain::Operations::Pricing

  describe '取引で入手できる種' do
    it '保全上の懸念が低い一般的な種(ニホンザル=低危険)は取引可能であること' do
      expect(catalog.japanese_macaque.tradeable?).to be(true)
      expect(catalog.koi.tradeable?).to be(true)
    end

    it '購入価格は体格に応じて定まること(取引可能な種どうしで体格の大きい方が高い)' do
      expect(pricing.acquisition_price(catalog.japanese_macaque))
        .to be > pricing.acquisition_price(catalog.koi)
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
