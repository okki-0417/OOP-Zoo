# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      ZooStatistics = Data.define(
        :population, :species_count, :threatened_count, :births, :deaths_by_cause,
        :revenue, :balance, :reputation
      )
    end
  end
end
