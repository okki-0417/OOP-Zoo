# frozen_string_literal: true

FactoryBot.define do
  factory :operating do
    zoo
    sequence(:day)
    visitors { 0 }
    income { Money.zero }
    cost { Money.zero }
    deaths { 0 }
    reputation { 50 }
  end
end
