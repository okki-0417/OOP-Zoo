# frozen_string_literal: true

FactoryBot.define do
  factory :animal do
    species { SpeciesCatalog.lion }
    sequence(:name) { |n| "動物#{n}" }
    sex { Animal::Sex.male }
    max_health { 100 }
    age_in_days { (species.maturity_age_years + 1) * Animal::LifeStage::DAYS_PER_YEAR }

    trait :female do
      sex { Animal::Sex.female }
    end

    trait :newborn do
      age_in_days { 0 }
    end
  end
end
