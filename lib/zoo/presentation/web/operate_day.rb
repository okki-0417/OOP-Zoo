# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class OperateDay < Action
        def call(_params)
          report = @container.operate_day.call
          [200, {
            visitors: report.visitors, income: report.income.to_s, cost: report.cost.to_s,
            deaths: report.deaths, reputation: report.reputation,
            balance: report.balance.to_s, bankrupt: report.bankrupt
          }]
        end
      end
    end
  end
end
