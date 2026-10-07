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
            ApplicationRecord.transaction do
              keeper = Domain::Keeper.find_by(id: @command.keeper_id)
              raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

              enclosure = Domain::Enclosure.find_by(id: @command.enclosure_id)
              raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

              Domain::Tending.new(keeper:, enclosure:, occupancy: Domain::Occupancy.of(enclosure)).perform
              enclosure
            end
          end
        end
      end
    end
  end
end
