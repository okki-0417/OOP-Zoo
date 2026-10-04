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
              ReadModels::EnclosureSummary.new(
                id: enclosure.id.to_s,
                name: enclosure.name,
                population: @command.housings.occupants_of(enclosure).size,
                capacity: enclosure.capacity,
                cleanliness: enclosure.cleanliness_level,
                filthy: enclosure.filthy?
              )
            end
          end
        end
      end
    end
  end
end
