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
            enclosure = @command.unit_of_work.run do
              keeper = @command.keepers.find(@command.keeper_id)
              raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

              enclosure = @command.enclosures.find(@command.enclosure_id)
              raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

              Domain::Cleaning.new(keeper: keeper, enclosure: enclosure, amount: @command.amount).perform
              @command.enclosures.save(enclosure)
              @command.keepers.save(keeper)
              enclosure
            end
            ReadModels::EnclosureProfile.housed(enclosure, housings: @command.housings)
          end
        end
      end
    end
  end
end
