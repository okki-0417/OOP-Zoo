# frozen_string_literal: true

FactoryBot.define do
  factory :acquiring do
    zoo
    animal { association :animal, zoo: }
    day { 0 }
    cost { Money.zero }
  end
end
