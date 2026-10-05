# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class RenameAnimal
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:rename_animal) do
            @command.unit_of_work.run do
              animal = @command.animals.find(@command.animal_id)
              raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

              animal.change_name(@command.new_name)
              @command.animals.save(animal)
              animal
            end
          end
        end
      end
    end
  end
end
