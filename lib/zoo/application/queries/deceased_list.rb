# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class DeceasedList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:deceased_list) do
            @command.animals.all_deceased.map do |animal|
              ReadModels::DeceasedRecord.new(name: animal.name, species: animal.species_name, cause: animal.cause_of_death)
            end
          end
        end
      end
    end
  end
end
