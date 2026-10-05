# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class KeeperList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:keeper_list) do
            @command.keepers.all.map { |keeper| { keeper:, enclosures: @command.assignments.enclosures_of(keeper) } }
          end
        end
      end
    end
  end
end
