# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class OperatingHistory
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:operating_history) do
            @command.operatings.all
          end
        end
      end
    end
  end
end
