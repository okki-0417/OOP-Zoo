# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Feeding
      RSpec.describe NutritionPolicy do
        let(:catalog) { Taxonomy::SpeciesCatalog }
        let(:foods) { FoodCatalog }

        describe '.required_variety' do
          it '受け入れカテゴリが1つの肉食は1であること' do
            expect(described_class.required_variety(catalog.lion)).to eq(1)
          end

          it '受け入れカテゴリが多い雑食でも上限2であること' do
            expect(described_class.required_variety(catalog.japanese_macaque)).to eq(2)
          end
        end

        describe '.offered_categories' do
          it '食性に合う餌のカテゴリを重複なく返すこと' do
            result = described_class.offered_categories(catalog.african_elephant, [foods.hay, foods.bamboo_leaf, foods.banana])
            expect(result).to contain_exactly(:plant, :fruit)
          end

          it '食性に合わない餌は除外すること' do
            result = described_class.offered_categories(catalog.african_elephant, [foods.hay, foods.horse_meat])
            expect(result).to contain_exactly(:plant)
          end
        end

        describe '.balanced?' do
          it '必要カテゴリ数を満たせば true' do
            expect(described_class.balanced?(catalog.lion, [foods.horse_meat])).to be(true)
          end

          it '必要カテゴリ数に届かなければ false' do
            expect(described_class.balanced?(catalog.african_elephant, [foods.hay])).to be(false)
          end

          it '空の給餌は false' do
            expect(described_class.balanced?(catalog.lion, [])).to be(false)
          end
        end
      end
    end
  end
end
