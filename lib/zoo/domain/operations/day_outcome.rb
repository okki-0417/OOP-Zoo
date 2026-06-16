# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      class DayOutcome
        attr_reader :visitors, :income, :cost, :deaths, :afflicted

        def initialize(visitors:, income:, cost:, deaths:, afflicted:)
          @visitors = visitors
          @income = income
          @cost = cost
          @deaths = deaths
          @afflicted = afflicted
          freeze
        end

        def outbreak_name
          @afflicted&.name&.to_s
        end
      end
    end
  end
end
