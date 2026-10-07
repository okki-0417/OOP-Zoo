# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '栄養バランスと餌の多様性' do
  # 栄養が満たされるかは「ある個体にその日の餌を与えたとき、種類が偏っていないか」
  # という給餌の判定として観測される。
  def adequate?(species, foods)
    Feeding.new(animal: build_adult(species), foods: foods).nutritionally_adequate?
  end

  describe '単一カテゴリの食性(肉食ライオン)' do
    it '肉を与えれば栄養が満たされること(多様性は問われない)' do
      expect(adequate?(SpeciesCatalog.lion, [FoodCatalog.horse_meat])).to be(true)
    end
  end

  describe '幅広い食性(草食アフリカゾウ)' do
    it '1カテゴリ(植物)の餌ばかりだと栄養が偏ること' do
      expect(adequate?(SpeciesCatalog.african_elephant, [FoodCatalog.hay, FoodCatalog.bamboo_leaf])).to be(false)
    end

    it '植物と果実など複数カテゴリを与えると栄養が満たされること' do
      expect(adequate?(SpeciesCatalog.african_elephant, [FoodCatalog.hay, FoodCatalog.banana])).to be(true)
    end
  end

  describe '幅広い食性(雑食ニホンザル)' do
    it '果実ばかりだと栄養が偏ること' do
      expect(adequate?(SpeciesCatalog.japanese_macaque, [FoodCatalog.banana, FoodCatalog.apple])).to be(false)
    end

    it '果実と昆虫など複数カテゴリを与えると栄養が満たされること' do
      expect(adequate?(SpeciesCatalog.japanese_macaque, [FoodCatalog.banana, FoodCatalog.cricket])).to be(true)
    end
  end

  describe '食性に合わない餌' do
    it '栄養として数えられないこと(草食動物に肉を混ぜても多様性に寄与しない)' do
      expect(adequate?(SpeciesCatalog.african_elephant, [FoodCatalog.hay, FoodCatalog.horse_meat])).to be(false)
    end
  end

  describe '欠食' do
    it '何も与えなければ栄養は満たされないこと' do
      expect(adequate?(SpeciesCatalog.lion, [])).to be(false)
    end
  end

  describe '1日の食事と栄養状態' do
    def fed(animal, *foods_of_the_day)
      keeper = build_keeper(TaxonClass.mammal)
      foods_of_the_day.each { |food| Feeding.new(keeper:, animal:, foods: [food]).serve }
      animal
    end

    context '雑食のニホンザルに、同じ日のうちにバナナとコオロギを別々に与えると' do
      it '1日の終わりに果実と昆虫の2カテゴリがそろったとみなされ、栄養状態が保たれること' do
        monkey = fed(build_adult(SpeciesCatalog.japanese_macaque), FoodCatalog.banana, FoodCatalog.cricket)
        expect { monkey.settle_nutrition }.not_to(change { monkey.nutrition_level })
      end
    end

    context 'その日に何も与えないと' do
      it '1日の終わりに栄養状態が25下がること' do
        lion = build_adult(SpeciesCatalog.lion)
        expect { lion.settle_nutrition }.to change { lion.nutrition_level }.by(-25)
      end
    end

    context '前日にバランスよく食べていても' do
      it '翌日の食事は数え直しになり、その日に食べた分だけで評価されること' do
        monkey = fed(build_adult(SpeciesCatalog.japanese_macaque), FoodCatalog.banana, FoodCatalog.cricket)
        monkey.settle_nutrition
        fed(monkey, FoodCatalog.banana)
        expect { monkey.settle_nutrition }.to change { monkey.nutrition_level }.by(-25)
      end
    end

    context 'エリアで1日を過ごすと' do
      it '日々の締めくくりとして、その日の食事で栄養状態が評価されること' do
        enclosure = Enclosure.new(
          name: '猛獣舎', temperature: Temperature.celsius(20), capacity: 4
        )
        lion = build_adult(SpeciesCatalog.lion)
        occupancy = build_occupancy(enclosure, [lion])
        expect { AnimalDay.new(animal: lion, enclosure:, occupancy:).run }
          .to change { lion.nutrition_level }.by(-25)
      end
    end
  end
end
