# frozen_string_literal: true

FactoryBot.define do
  factory :keeper do
    sequence(:name) { |n| "飼育員#{n}" }
    specialties { [TaxonClass.mammal] }
  end
end
