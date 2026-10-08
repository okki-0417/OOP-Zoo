# frozen_string_literal: true

module Types
  class Operating < BaseObject
    field :day, Integer, null: false
    field :visitors, Integer, null: false
    field :income, Integer, null: false
    field :cost, Integer, null: false
    field :expenses, [Expense], null: false
    field :net_income, Integer, null: false
    field :deaths, Integer, null: false
    field :balance, Integer, null: false
    field :reputation, Integer, null: false
    field :outbreak, String

    def income
      object.income.yen
    end

    def cost
      object.cost.yen
    end

    def net_income
      object.net_income.yen
    end

    def reputation
      object.reputation.score
    end

    def balance
      object.zoo.closing_balance(object.day).yen
    end
  end
end
