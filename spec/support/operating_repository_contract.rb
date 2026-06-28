# frozen_string_literal: true

RSpec.shared_examples 'an operating repository' do
  money   = Zoo::Domain::Shared::Money
  balance = Zoo::Domain::Shared::Balance

  def build_operating(day:, visitors: 10, outbreak: nil)
    Zoo::Domain::Operating.reconstitute(
      id: Zoo::Domain::Shared::Identifier.new, day: day, visitors: visitors,
      income: Zoo::Domain::Shared::Money.yen(20_000), cost: Zoo::Domain::Shared::Money.yen(8_000),
      deaths: 0, balance: Zoo::Domain::Shared::Balance.new(100_000), reputation: 50, outbreak: outbreak,
      total_visitors: visitors, total_revenue: Zoo::Domain::Shared::Money.yen(20_000)
    )
  end

  it 'save した運営記録を all で取り出せること' do
    repository.save(build_operating(day: 3, visitors: 42, outbreak: 'レオ'))

    record = repository.all.first
    expect(record.day).to eq(3)
    expect(record.visitors).to eq(42)
    expect(record.income).to eq(money.yen(20_000))
    expect(record.cost).to eq(money.yen(8_000))
    expect(record.balance).to eq(balance.new(100_000))
    expect(record.reputation).to eq(50)
    expect(record.outbreak).to eq('レオ')
  end

  it '記録が無ければ all は空であること' do
    expect(repository.all).to be_empty
  end

  it '複数日の記録を日付順で返すこと' do
    repository.save(build_operating(day: 2))
    repository.save(build_operating(day: 1))

    expect(repository.all.map(&:day)).to eq([1, 2])
  end

  it 'outbreak が無い日は nil を保持できること' do
    repository.save(build_operating(day: 1, outbreak: nil))

    expect(repository.all.first.outbreak).to be_nil
  end
end
