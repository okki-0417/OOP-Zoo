# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class TransferAnimal
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:transfer_animal) do
            @command.unit_of_work.run do
              target = @command.enclosures.find(@command.enclosure_id)
              raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if target.nil?

              animal = @command.animals.find(@command.animal_id)
              raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

              occupancy = @command.housings.all_occupancies.find { |o| o.enclosure == target } ||
                          Domain::Occupancy.new(housings: [], enclosure: target)
              housing = Domain::Housing.new(animal: animal, enclosure: target, occupancy: occupancy)
              housing.admission_violation!

              current = @command.housings.current_housing_of(animal)
              @command.housings.save(Domain::Releasing.of(current)) if current
              @command.housings.save(housing)
              animal
            end
          end
        end
      end
    end
  end
end
