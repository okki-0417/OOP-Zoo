# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AssignKeeper
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:assign_keeper) do
            @command.unit_of_work.run do
              keeper = @command.keepers.find(@command.keeper_id)
              raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

              enclosure = @command.enclosures.find(@command.enclosure_id)
              raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

              occupancy = @command.housings.all_occupancies.find { |o| o.enclosure == enclosure } ||
                          Domain::Occupancy.new(housings: [], enclosure: enclosure)
              assignment = Domain::Assignment.new(enclosure, @command.assignments.keepers_of(enclosure))
              tending = Domain::Tending.new(
                keeper: keeper, enclosure: enclosure, occupancy: occupancy, assignment: assignment
              )
              tending.violation!
              @command.assignments.save(tending)
            end
          end
        end
      end
    end
  end
end
