# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class OperateDay
        def initialize(open_for_a_day:, enclosures:, animals:, housings:, keepers:, veterinarians:, zoo:, unit_of_work:,
                       random: Random.new)
          @open_for_a_day = open_for_a_day
          @enclosures = enclosures
          @animals = animals
          @housings = housings
          @keepers = keepers
          @veterinarians = veterinarians
          @zoo = zoo
          @unit_of_work = unit_of_work
          @random = random
        end

        def call
          @unit_of_work.run do
            zoo  = @zoo.load
            dead = @open_for_a_day.call(season: zoo.season)

            enclosures = @enclosures.all
            animals    = @animals.all
            on_exhibit = @housings.all_occupants

            visitors = Domain::VisitorAttraction.new(
              on_exhibit:, reputation_factor: zoo.reputation_factor,
              admission_fee: zoo.admission_fee, buzz: zoo.buzz
            ).expected_visitors
            income = zoo.admit_visitors(visitors)

            cost = Domain::OperatingCost.new(
              enclosures:, staff: @keepers.all + @veterinarians.all, species: animals.map(&:species)
            ).amount
            zoo.spend(cost)

            afflicted = Domain::SpontaneousInfection.new(on_exhibit, @random).strike

            zoo.update_reputation(
              Domain::ReputationEvaluation.new(
                reputation: zoo.reputation, admission_fee: zoo.admission_fee,
                on_exhibit:, visitors:, dead:, afflicted:
              ).evaluated
            )
            zoo.advance_day

            @animals.save(afflicted) if afflicted
            @zoo.save(zoo)

            ReadModels::DayReport.new(
              visitors:, income:, cost:, deaths: dead.size,
              balance: zoo.balance, reputation: zoo.reputation_score, bankrupt: zoo.bankrupt?,
              outbreak: afflicted&.name
            )
          end
        end
      end
    end
  end
end
