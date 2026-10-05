# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class DischargeKeeper
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:discharge_keeper) do
            enclosure = @command.unit_of_work.run do
              keeper = @command.keepers.find(@command.keeper_id)
              raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

              enclosure = @command.enclosures.find(@command.enclosure_id)
              raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

              assignment = Domain::Assignment.new(enclosure, @command.assignments.keepers_of(enclosure))
              relieving = Domain::Relieving.of(current_tending!(keeper, enclosure), assignment: assignment)
              relieving.violation!
              @command.assignments.save(relieving)
              enclosure
            end
            {
              enclosure:,
              occupants: @command.housings.occupants_of(enclosure),
              keepers: @command.assignments.keepers_of(enclosure)
            }
          end
        end

        private

        def current_tending!(keeper, enclosure)
          @command.assignments.active_tending_of(keeper, enclosure) ||
            raise(Errors::AssignmentNotFound, "#{keeper.name}は#{enclosure.name}を担当していません")
        end
      end
    end
  end
end
