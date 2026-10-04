# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class SpeciesList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:species_list) do
            @command.species.all_by_code
          end
        end
      end
    end
  end
end
