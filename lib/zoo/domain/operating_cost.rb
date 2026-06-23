# frozen_string_literal: true

module Zoo
  module Domain
    class OperatingCost
      def initialize(enclosures:, staff:, species:)
        @enclosures = enclosures
        @staff = staff
        @species = species
      end

      def amount
        @enclosures.sum(Shared::Money.zero, &:daily_upkeep) +
          @staff.sum(Shared::Money.zero, &:salary) +
          @species.sum(Shared::Money.zero, &:daily_food_cost)
      end
    end
  end
end
