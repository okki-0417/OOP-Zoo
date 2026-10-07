# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Operating do
  let(:feed) do
    Operating::Expense.new(category: Operating::Expense::Category.feed, subject: 'ライオン', quantity: 3,
                           amount: Money.yen(4_500))
  end
  let(:operating) do
    Operating.create!(
      day: 1, visitors: 12, income: Money.yen(24_000), cost: Money.yen(4_500), deaths: 0,
      balance: Balance.new(119_500), reputation: 50, outbreak: nil,
      total_visitors: 12, total_revenue: Money.yen(24_000), expenses: [feed]
    )
  end

  it 'income・cost・netIncome・balance は ¥24,000・¥4,500・¥19,500・¥119,500 を円の整数で返すこと' do
    expect(run_graphql_field('Operating.income', operating)).to eq(24_000)
    expect(run_graphql_field('Operating.cost', operating)).to eq(4_500)
    expect(run_graphql_field('Operating.netIncome', operating)).to eq(19_500)
    expect(run_graphql_field('Operating.balance', operating)).to eq(119_500)
  end

  it 'expenses は保存した内訳(飼料費 ライオン×3 ¥4,500)を再読込後も返すこと' do
    expect(run_graphql_field('Operating.expenses', Operating.find(operating.id))).to eq([feed])
  end
end
