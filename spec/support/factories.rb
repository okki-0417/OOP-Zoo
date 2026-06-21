# frozen_string_literal: true

module Factories
  A = Zoo::Domain::Animal
  T = Zoo::Domain
  H = Zoo::Domain

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

  def build_pair(species, max_health: 100)
    [
      build_adult(species, name: "#{species.name_ja}♂", sex: A::Sex.male, max_health: max_health),
      build_adult(species, name: "#{species.name_ja}♀", sex: A::Sex.female, max_health: max_health)
    ]
  end

  def housed(animal, enclosure, day: 0)
    Zoo::Domain::Housing.record(animal: animal, enclosure: enclosure, occurred_on: day)
  end

  def released(housing, day: 0)
    Zoo::Domain::Release.of(housing, occurred_on: day)
  end

  def occupants_of(housings, enclosure)
    Zoo::Domain::Occupancy.new(housings.all).occupants_of(enclosure)
  end
end

RSpec.configure do |config|
  config.include Factories
end
