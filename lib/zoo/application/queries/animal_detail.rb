# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class AnimalDetail
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:animal_detail) do
            animal = @command.animals.find(@command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

            ReadModels::AnimalProfile.housed(animal, housings: @command.housings)
          end
        end
      end
    end
  end
end
