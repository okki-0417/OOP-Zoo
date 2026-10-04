# frozen_string_literal: true

module Factories
  def build_adult(species_key, name: 'X', sex: 'male', max_health: 100)
    species = SpeciesCatalog.find(species_key)
    age = (species.maturity_age_years + 1) * Animal::LifeStage::DAYS_PER_YEAR
    Animal.acquire(species_key: species_key, name: name, sex: sex, max_health: max_health, age_in_days: age)
  end

  def pen(name = '区画', capacity: 4, temp: 25)
    Enclosure.build(name: name, temperature: Temperature.celsius(temp), capacity: capacity)
  end

  def house(animal, enclosure)
    Housing.house(animal: animal, enclosure: enclosure, occupancy: Occupancy.of(enclosure))
  end

  # 収容審査(admission_violation!)を経ずに既存の入居事実だけを作る、テスト専用のセットアップ用ヘルパー
  def house_without_validation(animal, enclosure)
    housing = Housing.new
    housing.send(:animal=, animal)
    housing.send(:enclosure=, enclosure)
    housing.save!
    housing
  end
end

RSpec.configure do |config|
  config.include Factories
end
