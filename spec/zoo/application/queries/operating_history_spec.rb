# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::OperatingHistory do
  balance   = Zoo::Domain::Shared::Balance
  in_memory = Zoo::Infrastructure::InMemory

  def operating(day:, income:, cost:)
    Zoo::Domain::Operating.reconstitute(
      id: Zoo::Domain::Shared::Identifier.new,
      day: day, visitors: 30, income: Zoo::Domain::Shared::Money.yen(income),
      cost: Zoo::Domain::Shared::Money.yen(cost), deaths: 1,
      balance: Zoo::Domain::Shared::Balance.new(150_000), reputation: 55, outbreak: nil,
      total_visitors: 30, total_revenue: Zoo::Domain::Shared::Money.yen(income)
    )
  end

  it '運営記録を日次サマリ(純益込み)にして日付順で返すこと' do
    operatings = in_memory::InMemoryOperatingRepository.new
    operatings.save(operating(day: 2, income: 60_000, cost: 8_000))
    operatings.save(operating(day: 1, income: 40_000, cost: 8_000))

    history = described_class.new(operatings: operatings).call

    expect(history.map(&:day)).to eq([1, 2])
    expect(history.first.net_income).to eq(balance.new(32_000))
    expect(history.first.balance).to eq(balance.new(150_000))
    expect(history.first.reputation).to eq(55)
  end

  it '運営履歴が無ければ空を返すこと' do
    expect(described_class.new(operatings: in_memory::InMemoryOperatingRepository.new).call).to be_empty
  end
end
