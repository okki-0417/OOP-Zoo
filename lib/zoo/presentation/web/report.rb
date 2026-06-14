# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class Report < Action
        def call(_params)
          stats = @container.zoo_report.call
          [200, {
            population: stats.population, species: stats.species_count, threatened: stats.threatened_count,
            births: stats.births, deaths_by_cause: stats.deaths_by_cause, revenue: stats.revenue.to_s
          }]
        end
      end
    end
  end
end
