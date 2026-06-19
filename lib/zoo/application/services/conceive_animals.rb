# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class ConceiveAnimals
        def initialize(animals:, keepers:, zoo:, event_dispatcher:, unit_of_work:)
          @animals = animals
          @keepers = keepers
          @zoo = zoo
          @event_dispatcher = event_dispatcher
          @unit_of_work = unit_of_work
        end

        def call(command)
          events = @unit_of_work.run do
            sire = @animals.find(command.sire_id)
            raise Errors::AnimalNotFound, "動物 #{command.sire_id} は存在しません" if sire.nil?

            dam = @animals.find(command.dam_id)
            raise Errors::AnimalNotFound, "動物 #{command.dam_id} は存在しません" if dam.nil?

            keeper = find_keeper(command.keeper_id)

            zoo = @zoo.load

            Domain::Breeding.conceive(
              sire:, dam:, animal_lookup:,
              day: zoo.day, keeper:, season: zoo.season
            )

            @animals.save(dam)
            dam.pull_events
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

        def animal_lookup
          ->(id) { @animals.find(id) }
        end
      end
    end
  end
end
