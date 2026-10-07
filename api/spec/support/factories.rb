# frozen_string_literal: true

module Factories
  A = Zoo::Domain::Animal
  T = Zoo::Domain

  def build_adult(species, name: 'X', sex: A::Sex.male, max_health: 100)
    age = (species.maturity_age_years + 1) * A::LifeStage::DAYS_PER_YEAR
    A.new(
      species: species, name: name, sex: sex, max_health: max_health, age_in_days: age
    )
  end

  def build_animal(species, name: 'X', sex: A::Sex.male, max_health: 100, age_in_days: 0)
    A.new(
      species: species, name: name, sex: sex, max_health: max_health, age_in_days: age_in_days
    )
  end

  def build_keeper(*taxon_classes)
    taxon_classes = [Zoo::Domain::TaxonClass.mammal] if taxon_classes.empty?
    Zoo::Domain::Keeper.new(name: '飼育員', specialties: taxon_classes)
  end

  def create_enclosure(name: 'ライオンの丘', celsius: 28, capacity: 4, **)
    Zoo::Domain::Enclosure.create!(
      name:, temperature: Zoo::Domain::Shared::Temperature.celsius(celsius), capacity:, **
    )
  end

  def create_zoo(funds: 100_000, admission_fee: 2_000, **)
    money = Zoo::Domain::Shared::Money
    Zoo::Domain::Zoo.create!(name: 'テスト動物園', admission_fee: money.yen(admission_fee), funds: money.yen(funds), **)
  end

  def build_pair(species, max_health: 100)
    [
      build_adult(species, name: "#{species.name_ja}♂", sex: A::Sex.male, max_health: max_health),
      build_adult(species, name: "#{species.name_ja}♀", sex: A::Sex.female, max_health: max_health)
    ]
  end

  def build_occupancy(enclosure, animals)
    Zoo::Domain::Occupancy.new(enclosure:, occupants: animals)
  end

  def welfare_of(animal, enclosure, occupants, season: Zoo::Domain::Season.spring)
    occupancy = build_occupancy(enclosure, occupants)
    Zoo::Domain::Welfare.new(
      animal: animal,
      enclosure: enclosure,
      occupancy: occupancy,
      companionship: Zoo::Domain::Companionship.new(enclosure: enclosure, occupancy: occupancy, member: animal),
      thermal_suitability: Zoo::Domain::ThermalSuitability.new(animal, enclosure.effective_temperature(season))
    )
  end
end

RSpec.configure do |config|
  config.include Factories
end
