# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '栄養バランスと餌の多様性' do
  catalog = Zoo::Domain::SpeciesCatalog
  foods   = Zoo::Domain::FoodCatalog

  describe '単一カテゴリの食性(肉食ライオン)' do
    it '肉を与えれば栄養が満たされること(多様性は問われない)' do
      expect(catalog.lion.diet_satisfied_by?([foods.horse_meat])).to be(true)
    end
  end

  describe '幅広い食性(草食アフリカゾウ)' do
    it '1カテゴリ(植物)の餌ばかりだと栄養が偏ること' do
      expect(catalog.african_elephant.diet_satisfied_by?([foods.hay, foods.bamboo_leaf])).to be(false)
    end

    it '植物と果実など複数カテゴリを与えると栄養が満たされること' do
      expect(catalog.african_elephant.diet_satisfied_by?([foods.hay, foods.banana])).to be(true)
    end
  end

  describe '幅広い食性(雑食ニホンザル)' do
    it '果実ばかりだと栄養が偏ること' do
      expect(catalog.japanese_macaque.diet_satisfied_by?([foods.banana, foods.apple])).to be(false)
    end

    it '果実と昆虫など複数カテゴリを与えると栄養が満たされること' do
      expect(catalog.japanese_macaque.diet_satisfied_by?([foods.banana, foods.cricket])).to be(true)
    end
  end

  describe '食性に合わない餌' do
    it '栄養として数えられないこと(草食動物に肉を混ぜても多様性に寄与しない)' do
      expect(catalog.african_elephant.diet_satisfied_by?([foods.hay, foods.horse_meat])).to be(false)
    end
  end

  describe '欠食' do
    it '何も与えなければ栄養は満たされないこと' do
      expect(catalog.lion.diet_satisfied_by?([])).to be(false)
    end
  end
end
