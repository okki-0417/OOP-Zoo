# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AnimalList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:animal_list) do
            @command.animals.all
          end
        end
      end
    end
  end
end
