# frozen_string_literal: true

module Zoo
  module Domain
    module DailyOperation
      module_function

      def run(zoo:, enclosures:, animals:, dead:, staff_count:, random:)
        on_exhibit = enclosures.flat_map(&:occupants)

        visitors, income = VisitorAttraction.receive(zoo:, on_exhibit:)

        cost = OperatingCost.charge(zoo:, enclosures:, staff_count:, animals:)

        afflicted = SpontaneousInfection.apply(on_exhibit, random)

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
