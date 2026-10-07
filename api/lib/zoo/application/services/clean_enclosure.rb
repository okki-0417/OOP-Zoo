# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class CleanEnclosure
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:clean_enclosure) do
            ApplicationRecord.transaction do
              keeper = Domain::Keeper.find_by(id: @command.keeper_id)
              raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

              enclosure = Domain::Enclosure.find_by(id: @command.enclosure_id)
              raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

              Domain::Cleaning.new(keeper: keeper, enclosure: enclosure, amount: @command.amount).perform
              enclosure.save!
              keeper.save!
              enclosure
            end
          end
        end
      end
    end
  end
end
