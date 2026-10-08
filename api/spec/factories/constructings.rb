# frozen_string_literal: true

FactoryBot.define do
  factory :constructing do
    zoo
    enclosure { association :enclosure, zoo: }
    day { 0 }
    cost { Money.zero }
  end
end
