# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class OperatingHistory
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:operating_history) do
            @command.operatings.all.map do |operating|
              ReadModels::OperatingSummary.new(
                day: operating.day, visitors: operating.visitors,
                income: operating.income, cost: operating.cost, deaths: operating.deaths,
                balance: operating.balance, reputation: operating.reputation,
                net_income: operating.net_income, outbreak: operating.outbreak
              )
            end
          end
        end
      end
    end
  end
end
