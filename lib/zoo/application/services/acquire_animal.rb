# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AcquireAnimal
        def initialize(animals:, unit_of_work:)
          @animals = animals
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
            @animals.save(animal)
            animal
          end
        end
      end
    end
  end
end
