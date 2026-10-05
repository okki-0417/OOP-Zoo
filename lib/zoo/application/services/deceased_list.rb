# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class DeceasedList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:deceased_list) do
            @command.animals.all_deceased
          end
        end
      end
    end
  end
end
