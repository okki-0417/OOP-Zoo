# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class HouseAnimal
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:house_animal) do
            enclosure = @command.unit_of_work.run do
              enclosure = @command.enclosures.find(@command.enclosure_id)
              raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

              animal = @command.animals.find(@command.animal_id)
              raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

              occupancy = @command.housings.all_occupancies.find { |o| o.enclosure == enclosure } ||
                          Domain::Occupancy.new(housings: [], enclosure: enclosure)
              housing = Domain::Housing.new(animal: animal, enclosure: enclosure, occupancy: occupancy)
              housing.admission_violation!

              @command.housings.save(housing)
              enclosure
            end
            ReadModels::EnclosureProfile.housed(
              enclosure, housings: @command.housings, assignments: @command.assignments
            )
          end
        end
      end
    end
  end
end
