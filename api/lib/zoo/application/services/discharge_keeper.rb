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
            ApplicationRecord.transaction do
              keeper = Domain::Keeper.find_by(id: @command.keeper_id)
              raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

              enclosure = Domain::Enclosure.find_by(id: @command.enclosure_id)
              raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

              unless keeper.in_charge_of?(enclosure)
                raise Errors::AssignmentNotFound, "#{keeper.name}は#{enclosure.name}を担当していません"
              end

              Domain::Relieving.new(keeper:, enclosure:).perform
              enclosure
            end
          end
        end
      end
    end
  end
end
