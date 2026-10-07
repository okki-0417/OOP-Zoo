# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '代謝と体格' do
  def species_of(diet, kg)
    Species.new(
      name_ja: '検証種', scientific_name: "Test #{diet.label} #{kg}",
      taxon_class: TaxonClass.mammal, diet_type: diet,
      conservation_status: ConservationStatus.least_concern,
      habitable_temperature_range: Temperature.celsius(10)..Temperature.celsius(30),
      lifespan_years: 10, maturity_age_years: 2, gestation_period_days: 60,
      adult_weight: Weight.from_kilograms(kg)
    )
  end

  describe '空腹の進み方' do
    it '小型で代謝の高い種ほど速く空腹になること(イモリ > ゾウ)' do
      expect(SpeciesCatalog.japanese_fire_belly_newt.daily_hunger)
        .to be > SpeciesCatalog.african_elephant.daily_hunger
    end

    it '大型の種は1日あたりの空腹がライオンより進みにくいこと' do
      expect(SpeciesCatalog.african_elephant.daily_hunger)
        .to be < SpeciesCatalog.lion.daily_hunger
    end
  end

  describe '必要採食量' do
    def satiety(species, food)
      Feeding.new(animal: build(:animal, species:), foods: [food]).satiety
    end

    it '同じ餌でも小型種はよく満たされ、大型種はあまり満たされないこと(サル > ゾウ)' do
      banana = FoodCatalog.banana
      expect(satiety(SpeciesCatalog.japanese_macaque, banana))
        .to be > satiety(SpeciesCatalog.african_elephant, banana)
    end
  end

  describe '飼料費' do
    it '体格の大きい種ほど高くつくこと(ゾウ > サル)' do
      expect(SpeciesCatalog.african_elephant.daily_food_cost)
        .to be > SpeciesCatalog.japanese_macaque.daily_food_cost
    end

    it '同じ体格でも肉食(捕食性)の方が高くつくこと' do
      carnivore = species_of(DietType.carnivore, 100)
      herbivore = species_of(DietType.herbivore, 100)
      expect(carnivore.daily_food_cost).to be > herbivore.daily_food_cost
    end
  end
end
