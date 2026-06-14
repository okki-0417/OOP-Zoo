# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class RenameAnimal
        def initialize(animals:, event_dispatcher:, unit_of_work:)
          @animals = animals
          @event_dispatcher = event_dispatcher
          @unit_of_work = unit_of_work
        end

        def call(command)
          animal, events = @unit_of_work.run do
            animal = @animals.find(command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{command.animal_id} は存在しません" if animal.nil?

            animal.change_name(command.new_name)
            @animals.save(animal)
            [animal, animal.pull_events]
          end

          @event_dispatcher.publish(events)
          animal
        end
      end
    end
  end
end
