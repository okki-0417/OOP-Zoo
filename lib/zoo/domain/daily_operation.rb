# frozen_string_literal: true

module Zoo
  module Domain
    module DailyOperation
      module_function

      def run(zoo:, enclosures:, animals:, dead:, staff_count:, random:)
        on_exhibit = enclosures.flat_map(&:occupants)

        visitors = VisitorAttraction.expected_visitors(
          on_exhibit,
          zoo.reputation,
          zoo.admission_fee,
          buzz: zoo.buzz
        )

        income = zoo.admit_visitors(visitors)

        cost = OperatingCost.daily(
          enclosures:,
          staff: staff_count,
          species: animals.map(&:species)
        )

        zoo.spend(cost)

        afflicted = OutbreakPolicy.strike(on_exhibit, random)
        afflicted&.fall_ill(IllnessCatalog.parasite)

        ReputationEvaluation.evaluate(zoo:, on_exhibit:, visitors:, dead:, afflicted:)

        zoo.advance_day

        DayOutcome.new(
          visitors:,
          income:,
          cost:,
          deaths: dead.size,
          afflicted:
        )
      end

    end
  end
end
