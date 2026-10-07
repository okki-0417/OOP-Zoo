# frozen_string_literal: true

FactoryBot.define do
  factory :zoo do
    name { 'テスト動物園' }
    admission_fee { Money.yen(2_000) }
    funds { Money.yen(100_000) }
  end
end
