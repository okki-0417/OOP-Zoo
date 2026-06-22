# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AssignKeeper
        def initialize(keepers:, enclosures:, housings:, assignments:, unit_of_work:)
          @keepers = keepers
          @enclosures = enclosures
          @housings = housings
          @assignments = assignments
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            keeper = @keepers.find(command.keeper_id)
            raise Errors::KeeperNotFound, "飼育員 #{command.keeper_id} は存在しません" if keeper.nil?

            enclosure = @enclosures.find(command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{command.enclosure_id} は存在しません" if enclosure.nil?

            occupants = @housings.occupants_of(enclosure)
            keepers = @assignments.keepers_of(enclosure)
            tending = Domain::Tending.new(
              keeper: keeper, enclosure: enclosure, occupants: occupants, keepers: keepers
            )
            tending.violation!
            @assignments.save(tending)
          end
        end
      end
    end
  end
end
