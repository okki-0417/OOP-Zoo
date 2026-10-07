# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Operating do
  it 'operatings { expenses } は、内訳(飼料費 ライオン×3 ¥4,500)を category FEED・subject・quantity・amount で返すこと' do
    Operating.create!(
      day: 1, visitors: 0, income: Money.zero, cost: Money.yen(4_500), deaths: 0,
      balance: Balance.new(0), reputation: 50, outbreak: nil,
      total_visitors: 0, total_revenue: Money.zero,
      expenses: [Operating::Expense.new(category: Operating::Expense::Category.feed, subject: 'ライオン', quantity: 3,
                                        amount: Money.yen(4_500))]
    )

    response = OopZooSchema.execute(
      '{ operatings { expenses { category subject quantity amount } } }'
    ).to_h

    expect(response.dig('data', 'operatings', 0, 'expenses')).to eq(
      [{ 'category' => 'FEED', 'subject' => 'ライオン', 'quantity' => 3, 'amount' => 4_500 }]
    )
  end
end
