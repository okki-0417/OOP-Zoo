# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '代謝と体格' do
  catalog    = Zoo::Domain::Taxonomy::SpeciesCatalog
  metabolism = Zoo::Domain::Husbandry::Metabolism
  foods      = Zoo::Domain::Feeding::FoodCatalog
  taxonomy   = Zoo::Domain::Taxonomy

  def species_of(diet, kg)
    Zoo::Domain::Taxonomy::Species.new(
      name_ja: '検証種', scientific_name: "Test #{diet.label} #{kg}",
      taxon_class: Zoo::Domain::Taxonomy::TaxonClass.mammal, diet_type: diet,
      conservation_status: Zoo::Domain::Taxonomy::ConservationStatus.least_concern,
      habitable_temperature_range: Zoo::Domain::Shared::Temperature.celsius(10)..Zoo::Domain::Shared::Temperature.celsius(30),
      lifespan_years: 10, maturity_age_years: 2, gestation_period_days: 60,
      adult_weight: Zoo::Domain::Taxonomy::Weight.from_kilograms(kg)
    )
  end

  describe '空腹の進み方' do
    it '小型で代謝の高い種ほど速く空腹になること(イモリ > ゾウ)' do
      expect(metabolism.daily_hunger(catalog.japanese_fire_belly_newt))
        .to be > metabolism.daily_hunger(catalog.african_elephant)
    end

    it '大型の種は1日あたりの空腹がライオンより進みにくいこと' do
      expect(metabolism.daily_hunger(catalog.african_elephant))
        .to be < metabolism.daily_hunger(catalog.lion)
    end
  end

  describe '必要採食量' do
    it '同じ餌でも小型種はよく満たされ、大型種はあまり満たされないこと(サル > ゾウ)' do
      banana = foods.banana
      expect(metabolism.satiety(catalog.japanese_macaque, banana))
        .to be > metabolism.satiety(catalog.african_elephant, banana)
    end
  end

  describe '飼料費' do
    it '体格の大きい種ほど高くつくこと(ゾウ > サル)' do
      expect(metabolism.daily_food_cost(catalog.african_elephant))
        .to be > metabolism.daily_food_cost(catalog.japanese_macaque)
    end

    it '同じ体格でも肉食(捕食性)の方が高くつくこと' do
      carnivore = species_of(taxonomy::DietType.carnivore, 100)
      herbivore = species_of(taxonomy::DietType.herbivore, 100)
      expect(metabolism.daily_food_cost(carnivore)).to be > metabolism.daily_food_cost(herbivore)
    end
  end
end
