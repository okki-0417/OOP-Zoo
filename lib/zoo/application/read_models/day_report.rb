# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      DayReport = Data.define(:visitors, :income, :cost, :deaths, :balance, :reputation, :bankrupt, :outbreak)
    end
  end
end
