# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Presentation::Graphql::Types::Operating do
  money   = Zoo::Domain::Shared::Money
  expense = Zoo::Domain::Operating::Expense

  it 'operatings { expenses } は、内訳(飼料費 ライオン×3 ¥4,500)を category FEED・subject・quantity・amount で返すこと' do
    Zoo::Domain::Operating.create!(
      day: 1, visitors: 0, income: money.zero, cost: money.yen(4_500), deaths: 0,
      balance: Zoo::Domain::Shared::Balance.new(0), reputation: 50, outbreak: nil,
      total_visitors: 0, total_revenue: money.zero,
      expenses: [expense.new(category: expense::Category.feed, subject: 'ライオン', quantity: 3,
                             amount: money.yen(4_500))]
    )

    response = Zoo::Presentation::Graphql::Schema.execute(
      '{ operatings { expenses { category subject quantity amount } } }'
    ).to_h

    expect(response.dig('data', 'operatings', 0, 'expenses')).to eq(
      [{ 'category' => 'FEED', 'subject' => 'ライオン', 'quantity' => 3, 'amount' => 4_500 }]
    )
  end
end
