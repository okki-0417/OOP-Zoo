# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Species do
      catalog = SpeciesCatalog

      describe '#acquisition_price' do
        it '基本価格＋希少性(ランク×単価)＋体重(kg×単価)で算出すること(ライオン=49,500円)' do
          expect(catalog.lion.acquisition_price).to eq(Shared::Money.yen(49_500))
        end

        it '極小の無脊椎(ヘラクレスオオカブト)でも基本価格を下回らないこと' do
          expect(catalog.hercules_beetle.acquisition_price.yen).to be >= Species::ACQUISITION_BASE_YEN
        end
      end
    end
  end
end
