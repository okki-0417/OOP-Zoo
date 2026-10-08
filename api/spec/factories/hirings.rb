# frozen_string_literal: true

FactoryBot.define do
  factory :hiring do
    zoo
    employee { association :keeper, zoo: }
    day { 0 }
    cost { Money.zero }
  end
end
