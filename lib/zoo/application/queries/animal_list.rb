# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class AnimalList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:animal_list) do
            @command.animals.all.map { |animal| ReadModels::AnimalSummary.of(animal) }
          end
        end
      end
    end
  end
end
