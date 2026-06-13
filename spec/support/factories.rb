# frozen_string_literal: true

# テストで動物個体やエリアを手早く組み立てるためのファクトリ。
# RSpec設定で全exampleにmixinする。
module Factories
  A = Zoo::Domain::Animal
  T = Zoo::Domain::Taxonomy
  H = Zoo::Domain::Husbandry

  # 成体(繁殖可能な日齢)の個体を作る。
  def build_adult(species, name: 'X', sex: A::Sex.male, max_health: 100)
    age = (species.maturity_age_years + 1) * A::LifeStage::DAYS_PER_YEAR
    A.new(
      species: species, name: name, sex: sex, max_health: max_health, age_in_days: age
    )
  end

  # 任意の日齢の個体を作る。
  def build_animal(species, name: 'X', sex: A::Sex.male, max_health: 100, age_in_days: 0)
    A.new(
      species: species, name: name, sex: sex, max_health: max_health, age_in_days: age_in_days
    )
  end

  # 雌雄ひと組の成体ペアを作る。
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
