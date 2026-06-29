# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class NameAnimal
        def initialize(animals:, unit_of_work:)
          @animals = animals
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            animal = @animals.find(command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{command.animal_id} は存在しません" if animal.nil?

            animal.name_animal(name: command.name)

            @animals.save(animal)
          end
          nil
        end
      end
    end
  end
end
