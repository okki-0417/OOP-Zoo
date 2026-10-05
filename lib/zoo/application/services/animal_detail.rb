# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AnimalDetail
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:animal_detail) do
            animal = @command.animals.find(@command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

            { animal:, enclosure: animal.alive? ? @command.housings.current_housing_of(animal)&.enclosure : nil }
          end
        end
      end
    end
  end
end
