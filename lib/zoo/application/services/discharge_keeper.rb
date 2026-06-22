# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class DischargeKeeper
        def initialize(keepers:, enclosures:, assignments:, unit_of_work:)
          @keepers = keepers
          @enclosures = enclosures
          @assignments = assignments
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            keeper = @keepers.find(command.keeper_id)
            raise Errors::KeeperNotFound, "飼育員 #{command.keeper_id} は存在しません" if keeper.nil?

            enclosure = @enclosures.find(command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{command.enclosure_id} は存在しません" if enclosure.nil?

            @assignments.save(Domain::Relieving.of(current_assignment!(keeper, enclosure).tending))
          end
        end

        private

        def current_assignment!(keeper, enclosure)
          @assignments.active_assignment_of(keeper, enclosure) ||
            raise(Errors::AssignmentNotFound, "#{keeper.name}は#{enclosure.name}を担当していません")
        end
      end
    end
  end
end
