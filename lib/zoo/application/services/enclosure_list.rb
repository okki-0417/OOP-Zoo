# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class EnclosureList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:enclosure_list) do
            @command.enclosures.all.map do |enclosure|
              {
                enclosure:,
                occupants: @command.housings.occupants_of(enclosure),
                keepers: @command.assignments.keepers_of(enclosure)
              }
            end
          end
        end
      end
    end
  end
end
