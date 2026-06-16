# frozen_string_literal: true

module Factories
  A = Zoo::Domain::Animal
  T = Zoo::Domain::Taxonomy
  H = Zoo::Domain::Husbandry

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
end

RSpec.configure do |config|
  config.include Factories
end
