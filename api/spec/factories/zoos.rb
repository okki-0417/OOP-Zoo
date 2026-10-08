# frozen_string_literal: true

FactoryBot.define do
  factory :zoo do
    user
    name { 'テスト動物園' }
    admission_fee { Money.yen(2_000) }
    opening_funds { Money.yen(100_000) }
  end
end
