# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Species do
  describe '#acquisition_price' do
    subject(:price) { species.acquisition_price }

    context 'ライオンのとき' do
      let(:species) { SpeciesCatalog.lion }

      it '基本価格＋希少性(ランク×単価)＋体重(kg×単価)の ¥49,500 を返すこと' do
        expect(price).to eq(Money.yen(49_500))
      end
    end

    context '極小の無脊椎(ヘラクレスオオカブト)のとき' do
      let(:species) { SpeciesCatalog.hercules_beetle }

      it 'ACQUISITION_BASE_YEN 以上を返すこと' do
        expect(price.yen).to be >= Species::ACQUISITION_BASE_YEN
      end
    end
  end
end
