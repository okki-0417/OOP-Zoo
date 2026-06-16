# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      module OperatingCost
        module_function

        UPKEEP_PER_ENCLOSURE = 5_000
        CLIMATE_CONTROL_RUNNING_YEN = 4_000
        SALARY_PER_STAFF = 12_000

        def daily(enclosures:, staff:, species:)
          upkeep = enclosures.sum(0) { |e| UPKEEP_PER_ENCLOSURE + (e.climate_controlled? ? CLIMATE_CONTROL_RUNNING_YEN : 0) }
          salaries = SALARY_PER_STAFF * staff
          food = species.sum(0) { |s| Husbandry::Metabolism.daily_food_cost(s).yen }
          Shared::Money.yen(upkeep + salaries + food)
        end
      end
    end
  end
end
