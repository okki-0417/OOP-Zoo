# frozen_string_literal: true

FactoryBot.define do
  factory :enclosure do
    transient do
      celsius { 28 }
    end

    sequence(:name) { |n| "エリア#{n}" }
    temperature { Temperature.celsius(celsius) }
    capacity { 4 }
  end
end
