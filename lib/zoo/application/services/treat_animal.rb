# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class TreatAnimal
        def initialize(veterinarians:, animals:, unit_of_work:)
          @veterinarians = veterinarians
          @animals = animals
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            vet = @veterinarians.find(command.veterinarian_id)
            raise Errors::VeterinarianNotFound, "獣医 #{command.veterinarian_id} は存在しません" if vet.nil?

            animal = @animals.find(command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{command.animal_id} は存在しません" if animal.nil?

            vet.treat(animal)
            @animals.save(animal)
            animal
          end
        end
      end
    end
  end
end
