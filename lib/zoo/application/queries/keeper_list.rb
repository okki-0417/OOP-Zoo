# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class KeeperList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:keeper_list) do
            @command.keepers.all.map { |keeper| ReadModels::KeeperSummary.of(keeper) }
          end
        end
      end
    end
  end
end
