# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class ZooMapper
        def to_row(zoo)
          {
            name: zoo.name,
            admission_fee: zoo.admission_fee.yen,
            revenue: zoo.revenue.yen,
            visitor_count: zoo.visitor_count,
            balance: zoo.balance.yen,
            reputation: zoo.reputation.value,
            day: zoo.day
          }
        end

        def to_zoo(row)
          Domain::Zoo.reconstitute(
            name: row['name'],
            admission_fee: Domain::Shared::Money.yen(row['admission_fee']),
            revenue: Domain::Shared::Money.yen(row['revenue']),
            visitor_count: row['visitor_count'],
            balance: Domain::Shared::Balance.new(row['balance']),
            reputation: Domain::Reputation.new(row['reputation']),
            day: row['day']
          )
        end
      end
    end
  end
end
