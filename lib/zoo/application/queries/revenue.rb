# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class Revenue
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:revenue) do
            @command.zoo.load.revenue
          end
        end
      end
    end
  end
end
