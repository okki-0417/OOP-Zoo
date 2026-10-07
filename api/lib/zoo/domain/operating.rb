# frozen_string_literal: true

module Zoo
  module Domain
    class Operating < ApplicationRecord
      MONEY = Shared::ValueType.new(Shared::Money, load: Shared::Money.method(:yen), dump: :yen.to_proc)

      attribute :income, MONEY
      attribute :cost, MONEY
      attribute :total_revenue, MONEY
      attribute :balance, Shared::ValueType.new(Shared::Balance, dump: :yen.to_proc)
      attribute :expenses, Shared::ValueType.new(
        Array,
        load: ->(json) { JSON.parse(json).map { |row| Expense.from_h(row) } },
        dump: ->(expenses) { JSON.generate(expenses.map(&:to_h)) }
      ), default: -> { [] }
      attribute :casualties, default: -> { [] }

      def self.latest
        order(:day, :id).last
      end

      def self.none_yet
        new(total_visitors: 0, total_revenue: Shared::Money.zero)
      end

      def net_income
        Shared::Balance.new(income.yen - cost.yen)
      end

      def to_s
        "#{day}日目: 来園#{visitors}人 純益#{net_income}"
      end
    end
  end
end
