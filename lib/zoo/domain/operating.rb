# frozen_string_literal: true

module Zoo
  module Domain
    class Operating
      include Shared::Entity

      attr_reader :id, :day, :visitors, :income, :cost, :deaths, :balance, :reputation, :outbreak

      def initialize(day:, visitors:, income:, cost:, deaths:, balance:, reputation:, outbreak: nil,
                     id: Shared::Identifier.new)
        @id = id
        @day = day
        @visitors = visitors
        @income = income
        @cost = cost
        @deaths = deaths
        @balance = balance
        @reputation = reputation
        @outbreak = outbreak
      end

      def self.reconstitute(id:, day:, visitors:, income:, cost:, deaths:, balance:, reputation:, outbreak:)
        new(id: id, day: day, visitors: visitors, income: income, cost: cost, deaths: deaths,
            balance: balance, reputation: reputation, outbreak: outbreak)
      end

      def net_income
        Shared::Balance.new(@income.yen - @cost.yen)
      end

      def to_s
        "#{@day}日目: 来園#{@visitors}人 純益#{net_income}"
      end
    end
  end
end
