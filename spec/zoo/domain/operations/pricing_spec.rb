# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Operations
      RSpec.describe Pricing do
        catalog = Taxonomy::SpeciesCatalog

        describe '.acquisition_price' do
          it '基本価格＋希少性(ランク×単価)＋体重(kg×単価)で算出すること' do
            # ライオン: 20,000 + VU(rank2)×10,000 + 190kg×50 = 49,500
            expect(described_class.acquisition_price(catalog.lion)).to eq(Shared::Money.yen(49_500))
          end

          it '極小の無脊椎でも基本価格を下回らないこと' do
            expect(described_class.acquisition_price(catalog.hercules_beetle).yen)
              .to be >= Pricing::ACQUISITION_BASE_YEN
          end
        end

        describe '.enclosure_construction_cost' do
          it '基本建設費＋定員×1枠単価で算出すること' do
            expect(described_class.enclosure_construction_cost(capacity: 5)).to eq(Shared::Money.yen(80_000))
          end
        end

        describe '雇用の一時金' do
          it 'Money を返し、獣医は飼育員より高いこと' do
            expect(described_class.keeper_signing_fee).to be_a(Shared::Money)
            expect(described_class.veterinarian_signing_fee).to be > described_class.keeper_signing_fee
          end
        end
      end
    end
  end
end
