# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class TransferAnimal
        def initialize(enclosures:, animals:, housings:, unit_of_work:)
          @enclosures = enclosures
          @animals = animals
          @housings = housings
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            target = @enclosures.find(command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{command.enclosure_id} は存在しません" if target.nil?

            animal = @animals.find(command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{command.animal_id} は存在しません" if animal.nil?

            occupancy = Domain::Occupancy.new(@housings.events_for_enclosure(target.id))
            violation = occupancy.admission_violation(target, animal)
            raise violation if violation

            current = @housings.current_housing_of(animal)
            @housings.save(Domain::Release.of(current)) if current
            @housings.save(Domain::Housing.record(animal: animal, enclosure: target))
            target
          end
        end
      end
    end
  end
end
