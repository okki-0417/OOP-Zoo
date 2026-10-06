# frozen_string_literal: true

RSpec.shared_examples 'an operating repository' do
  money   = Zoo::Domain::Shared::Money
  balance = Zoo::Domain::Shared::Balance

  def build_operating(day:, visitors: 10, outbreak: nil, expenses: [])
    Zoo::Domain::Operating.reconstitute(
      expenses:,
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

  it '運営費の内訳(人件費 飼育員 田中 ¥12,000・飼料費 ライオン×3 ¥4,500)を順序どおり保持できること' do
    expense = Zoo::Domain::Operating::Expense
    breakdown = [
      expense.new(category: expense::Category.payroll, subject: '飼育員 田中', amount: money.yen(12_000)),
      expense.new(category: expense::Category.feed, subject: 'ライオン', quantity: 3, amount: money.yen(4_500))
    ]
    repository.save(build_operating(day: 1, expenses: breakdown))

    expect(repository.all.first.expenses).to eq(breakdown)
    expect(repository.latest.expenses).to eq(breakdown)
  end

  it '内訳は日ごとの記録に紐づき、別の日の内訳と混ざらないこと' do
    expense = Zoo::Domain::Operating::Expense
    upkeep = ->(name) { expense.new(category: expense::Category.upkeep, subject: name, amount: money.yen(5_000)) }
    repository.save(build_operating(day: 1, expenses: [upkeep.call('サバンナ')]))
    repository.save(build_operating(day: 2, expenses: [upkeep.call('熱帯館')]))

    expect(repository.all.map { |record| record.expenses.map(&:subject) }).to eq([['サバンナ'], ['熱帯館']])
  end

  it '同じ記録を保存し直すと、内訳は重複せず置き換わること' do
    expense = Zoo::Domain::Operating::Expense
    operating = build_operating(day: 1, expenses: [
                                  expense.new(category: expense::Category.upkeep, subject: 'サバンナ', amount: money.yen(5_000))
                                ])
    repository.save(operating)
    repository.save(operating)

    expect(repository.all.first.expenses.size).to eq(1)
  end

  it '内訳の無い記録は、内訳が空であること' do
    repository.save(build_operating(day: 1))

    expect(repository.all.first.expenses).to be_empty
  end

  it 'outbreak が無い日は nil を保持できること' do
    repository.save(build_operating(day: 1, outbreak: nil))

    expect(repository.all.first.outbreak).to be_nil
  end
end
