# frozen_string_literal: true

FactoryBot.define do
  factory :veterinarian do
    sequence(:name) { |n| "獣医#{n}" }
  end
end
