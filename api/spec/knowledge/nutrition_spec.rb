# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '栄養バランスと餌の多様性' do
  catalog = Zoo::Domain::SpeciesCatalog
  foods   = Zoo::Domain::FoodCatalog

  # 栄養が満たされるかは「ある個体にその日の餌を与えたとき、種類が偏っていないか」
  # という給餌の判定として観測される。
  def adequate?(species, foods)
    Zoo::Domain::Feeding.new(animal: build_adult(species), foods: foods).nutritionally_adequate?
  end

  describe '単一カテゴリの食性(肉食ライオン)' do
    it '肉を与えれば栄養が満たされること(多様性は問われない)' do
      expect(adequate?(catalog.lion, [foods.horse_meat])).to be(true)
    end
  end

  describe '幅広い食性(草食アフリカゾウ)' do
    it '1カテゴリ(植物)の餌ばかりだと栄養が偏ること' do
      expect(adequate?(catalog.african_elephant, [foods.hay, foods.bamboo_leaf])).to be(false)
    end

    it '植物と果実など複数カテゴリを与えると栄養が満たされること' do
      expect(adequate?(catalog.african_elephant, [foods.hay, foods.banana])).to be(true)
    end
  end

  describe '幅広い食性(雑食ニホンザル)' do
    it '果実ばかりだと栄養が偏ること' do
      expect(adequate?(catalog.japanese_macaque, [foods.banana, foods.apple])).to be(false)
    end

    it '果実と昆虫など複数カテゴリを与えると栄養が満たされること' do
      expect(adequate?(catalog.japanese_macaque, [foods.banana, foods.cricket])).to be(true)
    end
  end

  describe '食性に合わない餌' do
    it '栄養として数えられないこと(草食動物に肉を混ぜても多様性に寄与しない)' do
      expect(adequate?(catalog.african_elephant, [foods.hay, foods.horse_meat])).to be(false)
    end
  end

  describe '欠食' do
    it '何も与えなければ栄養は満たされないこと' do
      expect(adequate?(catalog.lion, [])).to be(false)
    end
  end

  describe '1日の食事と栄養状態' do
    def fed(animal, *foods_of_the_day)
      keeper = build_keeper(Zoo::Domain::TaxonClass.mammal)
      foods_of_the_day.each { |food| Zoo::Domain::Feeding.new(keeper:, animal:, foods: [food]).serve }
      animal
    end

    context '雑食のニホンザルに、同じ日のうちにバナナとコオロギを別々に与えると' do
      it '1日の終わりに果実と昆虫の2カテゴリがそろったとみなされ、栄養状態が保たれること' do
        monkey = fed(build_adult(catalog.japanese_macaque), foods.banana, foods.cricket)
        expect { monkey.settle_nutrition }.not_to(change { monkey.nutrition_level })
      end
    end

    context 'その日に何も与えないと' do
      it '1日の終わりに栄養状態が25下がること' do
        lion = build_adult(catalog.lion)
        expect { lion.settle_nutrition }.to change { lion.nutrition_level }.by(-25)
      end
    end

    context '前日にバランスよく食べていても' do
      it '翌日の食事は数え直しになり、その日に食べた分だけで評価されること' do
        monkey = fed(build_adult(catalog.japanese_macaque), foods.banana, foods.cricket)
        monkey.settle_nutrition
        fed(monkey, foods.banana)
        expect { monkey.settle_nutrition }.to change { monkey.nutrition_level }.by(-25)
      end
    end

    context 'エリアで1日を過ごすと' do
      it '日々の締めくくりとして、その日の食事で栄養状態が評価されること' do
        enclosure = Zoo::Domain::Enclosure.new(
          name: '猛獣舎', temperature: Zoo::Domain::Shared::Temperature.celsius(20), capacity: 4
        )
        lion = build_adult(catalog.lion)
        occupancy = build_occupancy(enclosure, [lion])
        expect { Zoo::Domain::AnimalDay.new(animal: lion, enclosure:, occupancy:).run }
          .to change { lion.nutrition_level }.by(-25)
      end
    end
  end
end
