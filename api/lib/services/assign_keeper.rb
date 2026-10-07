# frozen_string_literal: true

module Services
  class AssignKeeper
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:assign_keeper) do
        ApplicationRecord.transaction do
          keeper = ::Keeper.find_by(id: @command.keeper_id)
          raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

          enclosure = ::Enclosure.find_by(id: @command.enclosure_id)
          raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

          ::Tending.new(keeper:, enclosure:, occupancy: ::Occupancy.of(enclosure)).perform
          enclosure
        end
      end
    end
  end
end
