# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class TreatAnimal
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:treat_animal) do
            animal = @command.unit_of_work.run do
              vet = @command.veterinarians.find(@command.veterinarian_id)
              raise Errors::VeterinarianNotFound, "獣医 #{@command.veterinarian_id} は存在しません" if vet.nil?

              animal = @command.animals.find(@command.animal_id)
              raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

              Domain::Treating.new(veterinarian: vet, animal: animal).perform
              @command.animals.save(animal)
              animal
            end
            { animal:, enclosure: animal.alive? ? @command.housings.current_housing_of(animal)&.enclosure : nil }
          end
        end
      end
    end
  end
end
