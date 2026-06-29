# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class OperatingMapper
        Domain = Zoo::Domain

        def to_row(operating)
          {
            id: operating.id.to_s,
            day: operating.day,
            visitors: operating.visitors,
            income: operating.income.yen,
            cost: operating.cost.yen,
            deaths: operating.deaths,
            balance: operating.balance.yen,
            reputation: operating.reputation,
            outbreak: operating.outbreak,
            total_visitors: operating.total_visitors,
            total_revenue: operating.total_revenue.yen
          }
        end

        def to_aggregate(row)
          Domain::Operating.reconstitute(
            id: Domain::Shared::Identifier.new(row['id']),
            day: row['day'],
            visitors: row['visitors'],
            income: Domain::Shared::Money.yen(row['income']),
            cost: Domain::Shared::Money.yen(row['cost']),
            deaths: row['deaths'],
            balance: Domain::Shared::Balance.new(row['balance']),
            reputation: row['reputation'],
            outbreak: row['outbreak'],
            total_visitors: row['total_visitors'],
            total_revenue: Domain::Shared::Money.yen(row['total_revenue'])
          )
        end
      end
    end
  end
end
