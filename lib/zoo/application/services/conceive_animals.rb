# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class ConceiveAnimals
        def initialize(animals:, zoo:, event_dispatcher:, unit_of_work:)
          @animals = animals
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

            zoo = @zoo.load

            Domain::Breeding.new(sire:, dam:, day: zoo.day, season: zoo.season, parents: @animals.all)
                            .conceive

            @animals.save(dam)
            dam.pull_events
          end

          @event_dispatcher.notify(events)
          nil
        end
      end
    end
  end
end
