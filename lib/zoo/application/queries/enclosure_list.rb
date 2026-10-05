# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class EnclosureList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:enclosure_list) do
            @command.enclosures.all.map do |enclosure|
              ReadModels::EnclosureProfile.housed(enclosure, housings: @command.housings,
                                                             assignments: @command.assignments)
            end
          end
        end
      end
    end
  end
end
