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

        zoo.apply_reputation(
          ReputationPolicy.after_day(
            zoo.reputation,
            experience: VisitorExperience.score(
              condition: Condition.score(on_exhibit),
              fee: zoo.admission_fee
            ),
            exposure: visitors,
            events: news_of(dead, afflicted)
          )
        )

        zoo.advance_day

        DayOutcome.new(
          visitors:,
          income:,
          cost:,
          deaths: dead.size,
          afflicted:
        )
      end

      def news_of(dead, afflicted)
        events = dead.map { |a| ReputationEvent::Death.new(cause: :unknown, charisma: a.species.charisma) }
        events << ReputationEvent::Outbreak.new if afflicted
        events
      end
    end
  end
end
