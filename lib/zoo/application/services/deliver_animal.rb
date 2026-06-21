# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class DeliverAnimal
        BIRTH_BUZZ = 40

        def initialize(animals:, enclosures:, housings:, keepers:, breedings:, births:, zoo:, event_dispatcher:,
                       unit_of_work:)
          @animals = animals
          @enclosures = enclosures
          @housings = housings
          @keepers = keepers
          @breedings = breedings
          @births = births
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

            birth = Domain::Birth.new(
              sire: breeding.sire, dam: dam, day: zoo.day, season: zoo.season, keeper_id: keeper&.id
            ).deliver
            child = birth.offspring

            occupancy = Domain::Occupancy.new(enclosure, @housings.occupants_of(enclosure))
            housing = Domain::Housing.new(
              animal: child, enclosure: enclosure, occupancy: occupancy, occurred_on: zoo.day, keeper_id: keeper&.id
            )
            housing.admission_violation!

            @animals.save(dam)
            @animals.save(child)
            @births.save(birth)
            @housings.save(housing)

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
