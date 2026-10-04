# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class NameAnimal
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:name_animal) do
            @command.unit_of_work.run do
              animal = @command.animals.find(@command.animal_id)
              raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

              animal.name_animal(name: @command.name)

              @command.animals.save(animal)
            end
            nil
          end
        end
      end
    end
  end
end
