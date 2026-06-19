# frozen_string_literal: true

module Zoo
  module Domain
    module OperatingCost
      module_function

      UPKEEP_PER_ENCLOSURE = 5_000
      CLIMATE_CONTROL_RUNNING_YEN = 4_000
      SALARY_PER_STAFF = 12_000

      def charge(zoo:, enclosures:, staff_count:, animals:)
        cost = daily(enclosures:, staff: staff_count, species: animals.map(&:species))
        zoo.spend(cost)
        cost
      end

      def daily(enclosures:, staff:, species:)
        upkeep = enclosures.sum do |e|
          UPKEEP_PER_ENCLOSURE + (e.climate_controlled? ? CLIMATE_CONTROL_RUNNING_YEN : 0)
        end
        salaries = SALARY_PER_STAFF * staff
        food = species.sum { |s| s.daily_food_cost.yen }
        Shared::Money.yen(upkeep + salaries + food)
      end
    end
  end
end
