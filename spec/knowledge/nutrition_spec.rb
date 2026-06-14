# frozen_string_literal: true

require 'spec_helper'

# 栄養バランスと餌の多様性の知識。満腹かどうか(量)とは別に、種の食性が求める
# 餌カテゴリの「多様性」が満たされているか(質)を評価する。
# 幅広い食性(雑食・草食)ほど多様な餌を必要とし、単一カテゴリの食性は1種で足りる。
RSpec.describe '栄養バランスと餌の多様性' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  foods   = Zoo::Domain::Feeding::FoodCatalog
  policy  = Zoo::Domain::Feeding::NutritionPolicy

  describe '単一カテゴリの食性(肉食ライオン)' do
    it '肉を与えれば栄養が満たされること(多様性は問われない)' do
      expect(policy.balanced?(catalog.lion, [foods.horse_meat])).to be(true)
    end
  end

  describe '幅広い食性(草食アフリカゾウ)' do
    it '1カテゴリ(植物)の餌ばかりだと栄養が偏ること' do
      expect(policy.balanced?(catalog.african_elephant, [foods.hay, foods.bamboo_leaf])).to be(false)
    end

    it '植物と果実など複数カテゴリを与えると栄養が満たされること' do
      expect(policy.balanced?(catalog.african_elephant, [foods.hay, foods.banana])).to be(true)
    end
  end

  describe '幅広い食性(雑食ニホンザル)' do
    it '果実ばかりだと栄養が偏ること' do
      expect(policy.balanced?(catalog.japanese_macaque, [foods.banana, foods.apple])).to be(false)
    end

    it '果実と昆虫など複数カテゴリを与えると栄養が満たされること' do
      expect(policy.balanced?(catalog.japanese_macaque, [foods.banana, foods.cricket])).to be(true)
    end
  end

  describe '食性に合わない餌' do
    it '栄養として数えられないこと(草食動物に肉を混ぜても多様性に寄与しない)' do
      expect(policy.balanced?(catalog.african_elephant, [foods.hay, foods.horse_meat])).to be(false)
    end
  end

  describe '欠食' do
    it '何も与えなければ栄養は満たされないこと' do
      expect(policy.balanced?(catalog.lion, [])).to be(false)
    end
  end
end
