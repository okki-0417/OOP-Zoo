# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class DeliverAnimal
        BIRTH_BUZZ = 40

        def initialize(animals:, enclosures:, keepers:, breedings:, zoo:, event_dispatcher:, unit_of_work:)
          @animals = animals
          @enclosures = enclosures
          @keepers = keepers
          @breedings = breedings
          @zoo = zoo
          @event_dispatcher = event_dispatcher
          @unit_of_work = unit_of_work
        end

        def call(command)
          offspring, events = @unit_of_work.run do
            dam = @animals.find(command.dam_id)
            raise Errors::AnimalNotFound, "動物 #{command.dam_id} は存在しません" if dam.nil?

            enclosure = @enclosures.find(command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{command.enclosure_id} は存在しません" if enclosure.nil?

            keeper = find_keeper(command.keeper_id)

            breeding = @breedings.for_dam(dam.id)
            raise Errors::BreedingNotFound, "動物 #{command.dam_id} の受胎記録がありません" if breeding.nil?

            zoo = @zoo.load

            child = dam.deliver(sire_id: breeding.sire.id, occurred_on: zoo.day, season: zoo.season,
                                keeper_id: keeper&.id)

            @animals.save(dam)
            @animals.save(child)
            enclosure.admit(child)
            @enclosures.save(enclosure)

            zoo.generate_buzz(BIRTH_BUZZ)
            @zoo.save(zoo)

            [child, dam.pull_events]
          end

          @event_dispatcher.notify(events)
          offspring
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
