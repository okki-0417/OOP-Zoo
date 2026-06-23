# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Acquiring do
      catalog = SpeciesCatalog

      def zoo
        Zoo.new(name: '動物園', admission_fee: Shared::Money.yen(2_000), funds: Shared::Money.yen(100_000))
      end

      describe '#settle' do
        it '取引可能な種は取得価格ぶん購入され残高が減ること' do
          z = zoo
          macaque = build_adult(catalog.japanese_macaque)

          described_class.new(zoo: z, animal: macaque).settle

          expect(z.balance).to eq(Shared::Balance.new(100_000 - macaque.acquisition_price.yen))
        end

        it '絶滅危惧種(ライオン=VU)は購入されず、保全貢献として評判が上がること' do
          z = zoo
          before = z.reputation
          lion = build_adult(catalog.lion)

          described_class.new(zoo: z, animal: lion).settle

          expect(z.balance).to eq(Shared::Balance.new(100_000))
          expect(z.reputation).to be > before
        end
      end
    end
  end
end
