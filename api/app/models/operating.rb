# frozen_string_literal: true

class Operating < ApplicationRecord
  MONEY = ValueType.new(Money, load: Money.method(:yen), dump: :yen.to_proc)

  attribute :income, MONEY
  attribute :cost, MONEY
  attribute :total_revenue, MONEY
  attribute :balance, ValueType.new(Balance, dump: :yen.to_proc)
  attribute :expenses, ValueType.new(
    Array,
    load: ->(json) { JSON.parse(json).map { |row| Expense.from_h(row) } },
    dump: ->(expenses) { JSON.generate(expenses.map(&:to_h)) }
  ), default: -> { [] }
  attribute :casualties, default: -> { [] }

  def self.latest
    order(:day, :id).last
  end

  def self.none_yet
    new(total_visitors: 0, total_revenue: Money.zero)
  end

  def net_income
    Balance.new(income.yen - cost.yen)
  end

  def to_s
    "#{day}日目: 来園#{visitors}人 純益#{net_income}"
  end
end
