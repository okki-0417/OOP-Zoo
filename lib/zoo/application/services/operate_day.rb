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
            on_exhibit = Domain::Occupancy.new(@housings.all).all_occupants

            visitors, income = Domain::VisitorAttraction.receive(zoo:, on_exhibit:)
            cost             = Domain::OperatingCost.charge(zoo:, enclosures:, staff_count: staff_count, animals:)
            afflicted        = Domain::SpontaneousInfection.apply(on_exhibit, @random)
            Domain::ReputationEvaluation.evaluate(zoo:, on_exhibit:, visitors:, dead:, afflicted:)
            zoo.advance_day

            @animals.save(afflicted) if afflicted
            @zoo.save(zoo)

            ReadModels::DayReport.new(
              visitors:, income:, cost:, deaths: dead.size,
              balance: zoo.balance, reputation: zoo.reputation.score, bankrupt: zoo.bankrupt?,
              outbreak: afflicted&.name
            )
          end
        end

        private

        def staff_count
          @keepers.all.size + @veterinarians.all.size
        end
      end
    end
  end
end
