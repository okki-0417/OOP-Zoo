# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class MakeRounds
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:make_rounds) do
            @command.unit_of_work.run do
              keeper = @command.keepers.find(@command.keeper_id)
              raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

              reports = @command.assignments.enclosures_of(keeper).map { |enclosure| round(keeper, enclosure) }
              persist(keeper, reports)
              { keeper:, reports: }
            end
          end
        end

        private

        def round(keeper, enclosure)
          occupancy = @command.housings.all_occupancies.find { |candidate| candidate.enclosure == enclosure } ||
                      Domain::Occupancy.new(housings: [], enclosure:)
          Domain::Rounding.new(
            keeper:, occupancy:,
            assignment: Domain::Assignment.new(enclosure, @command.assignments.keepers_of(enclosure)),
            foods: @command.foods.all_by_code.values
          ).perform
        end

        def persist(keeper, reports)
          reports.each do |report|
            @command.enclosures.save(report.enclosure)
            report.fed.each { |animal| @command.animals.save(animal) }
          end
          @command.keepers.save(keeper)
        end
      end
    end
  end
end
