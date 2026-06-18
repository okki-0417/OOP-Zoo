# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '代謝と体格' do
  catalog    = Zoo::Domain::SpeciesCatalog
  foods      = Zoo::Domain::FoodCatalog
  taxonomy   = Zoo::Domain

  def species_of(diet, kg)
    Zoo::Domain::Species.new(
      name_ja: '検証種', scientific_name: "Test #{diet.label} #{kg}",
      taxon_class: Zoo::Domain::TaxonClass.mammal, diet_type: diet,
      conservation_status: Zoo::Domain::ConservationStatus.least_concern,
      habitable_temperature_range: Zoo::Domain::Shared::Temperature.celsius(10)..Zoo::Domain::Shared::Temperature.celsius(30),
      lifespan_years: 10, maturity_age_years: 2, gestation_period_days: 60,
      adult_weight: Zoo::Domain::Weight.from_kilograms(kg)
    )
  end

  describe '空腹の進み方' do
    it '小型で代謝の高い種ほど速く空腹になること(イモリ > ゾウ)' do
      expect(catalog.japanese_fire_belly_newt.daily_hunger)
        .to be > catalog.african_elephant.daily_hunger
    end

    it '大型の種は1日あたりの空腹がライオンより進みにくいこと' do
      expect(catalog.african_elephant.daily_hunger)
        .to be < catalog.lion.daily_hunger
    end
  end

  describe '必要採食量' do
    it '同じ餌でも小型種はよく満たされ、大型種はあまり満たされないこと(サル > ゾウ)' do
      banana = foods.banana
      expect(catalog.japanese_macaque.satiety_from(banana))
        .to be > catalog.african_elephant.satiety_from(banana)
    end
  end

  describe '飼料費' do
    it '体格の大きい種ほど高くつくこと(ゾウ > サル)' do
      expect(catalog.african_elephant.daily_food_cost)
        .to be > catalog.japanese_macaque.daily_food_cost
    end

    it '同じ体格でも肉食(捕食性)の方が高くつくこと' do
      carnivore = species_of(taxonomy::DietType.carnivore, 100)
      herbivore = species_of(taxonomy::DietType.herbivore, 100)
      expect(carnivore.daily_food_cost).to be > herbivore.daily_food_cost
    end
  end
end
