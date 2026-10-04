# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class Population
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:population) do
            @command.housings.all_occupants.size
          end
        end
      end
    end
  end
end
