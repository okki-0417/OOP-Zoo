# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class NameAnimal
        def initialize(animals:, keepers:, zoo:, event_dispatcher:, unit_of_work:)
          @animals = animals
          @keepers = keepers
          @zoo = zoo
          @event_dispatcher = event_dispatcher
          @unit_of_work = unit_of_work
        end

        def call(command)
          events = @unit_of_work.run do
            animal = @animals.find(command.animal_id)
            raise Errors::AnimalNotFound, "動物 #{command.animal_id} は存在しません" if animal.nil?

            keeper = find_keeper(command.keeper_id)

            zoo = @zoo.load

            animal.name_animal(name: command.name, keeper_id: keeper&.id, occurred_on: zoo.day)

            @animals.save(animal)
            animal.pull_events
          end

          @event_dispatcher.notify(events)
          nil
        end

        private

        def find_keeper(keeper_id)
          return nil if keeper_id.nil?

          keeper = @keepers.find(keeper_id)
          raise Errors::KeeperNotFound, "飼育員 #{keeper_id} は存在しません" if keeper.nil?

          keeper
        end
      end
    end
  end
end
