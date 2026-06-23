# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class CleanEnclosure
        def initialize(keepers:, enclosures:, unit_of_work:)
          @keepers = keepers
          @enclosures = enclosures
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            keeper = @keepers.find(command.keeper_id)
            raise Errors::KeeperNotFound, "飼育員 #{command.keeper_id} は存在しません" if keeper.nil?

            enclosure = @enclosures.find(command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{command.enclosure_id} は存在しません" if enclosure.nil?

            cleaning = Domain::Cleaning.new(
              keeper: keeper, enclosure: enclosure, amount: command.amount
            )
            cleaning.perform
            @enclosures.save(enclosure)
            enclosure
          end
        end
      end
    end
  end
end
