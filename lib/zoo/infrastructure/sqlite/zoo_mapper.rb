# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      # Zoo 集約 ⇄ 行 の変換(Data Mapper)。値オブジェクトを列に平坦化し、
      # 読み戻しはドメインの復元ファクトリ(Zoo.reconstitute)に委ねる。
      class ZooMapper
        def to_row(zoo)
          {
            name: zoo.name,
            admission_fee: zoo.admission_fee.yen,
            revenue: zoo.revenue.yen,
            visitor_count: zoo.visitor_count,
            balance: zoo.balance.yen,
            reputation: zoo.reputation.score,
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
            reputation: Domain::Operations::Reputation.new(row['reputation']),
            day: row['day']
          )
        end
      end
    end
  end
end
