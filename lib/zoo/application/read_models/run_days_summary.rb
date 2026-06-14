# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      RunDaysSummary = Data.define(:days, :total_deaths, :deaths_by_cause)
    end
  end
end
