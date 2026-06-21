# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class HouseAnimal
        def initialize(enclosures:, animals:, housings:, unit_of_work:)
          @enclosures = enclosures
          @animals = animals
          @housings = housings
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            enclosure = @enclosures.find(command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{command.enclosure_id} は存在しません" if enclosure.nil?

            animal = @animals.find(command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{command.animal_id} は存在しません" if animal.nil?

            occupancy = Domain::Occupancy.new(@housings.all)
            violation = occupancy.admission_violation(enclosure, animal)
            raise violation if violation

            @housings.save(Domain::Housing.record(animal: animal, enclosure: enclosure))
            enclosure
          end
        end
      end
    end
  end
end
