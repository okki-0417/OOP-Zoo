# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AcquireAnimal
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:acquire_animal) do
            species = @command.species.find(@command.species_code) or
              raise Errors::SpeciesNotFound, "未知の種です: #{@command.species_code}"

            animal = @command.unit_of_work.run do
              animal = Domain::Animal.new(
                species: species,
                name: @command.name,
                sex: Domain::Animal::Sex.new(@command.sex),
                max_health: @command.max_health,
                age_in_days: @command.age_in_days
              )

              zoo = @command.zoo.load
              Domain::Acquiring.new(zoo: zoo, animal: animal).settle
              @command.zoo.save(zoo)
              @command.animals.save(animal)
              animal
            end
            ReadModels::AnimalProfile.of(animal, enclosure: nil)
          end
        end
      end
    end
  end
end
