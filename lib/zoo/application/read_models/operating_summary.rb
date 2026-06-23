# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      OperatingSummary = Data.define(
        :day, :visitors, :income, :cost, :deaths, :balance, :reputation, :net_income, :outbreak
      )
    end
  end
end
