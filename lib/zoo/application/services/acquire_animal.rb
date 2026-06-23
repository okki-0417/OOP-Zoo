# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AcquireAnimal
        def initialize(animals:, zoo:, unit_of_work:)
          @animals = animals
          @zoo = zoo
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            animal = Domain::Animal.new(
              species: command.species,
              name: command.name,
              sex: command.sex,
              max_health: command.max_health,
              age_in_days: command.age_in_days
            )

            zoo = @zoo.load
            Domain::Acquiring.new(zoo: zoo, animal: animal).settle
            @zoo.save(zoo)
            @animals.save(animal)
            animal
          end
        end
      end
    end
  end
end
