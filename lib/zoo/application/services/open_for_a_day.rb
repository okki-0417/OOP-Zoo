# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class OpenForADay
        def initialize(enclosures:, animals:, event_dispatcher:, unit_of_work:)
          @enclosures = enclosures
          @animals = animals
          @event_dispatcher = event_dispatcher
          @unit_of_work = unit_of_work
        end

        def call(season: Domain::Season.spring)
          deceased = []

          @enclosures.all.each do |enclosure|
            dead, events = @unit_of_work.run do
              dead_animals = enclosure.pass_day(season: season)
              @enclosures.save(enclosure)
              enclosure.occupants.each { |animal| @animals.save(animal) }
              dead_animals.each { |animal| @animals.save(animal) }
              [dead_animals, dead_animals.flat_map(&:pull_events)]
            end

            @event_dispatcher.publish(events)
            deceased.concat(dead)
          end

          deceased
        end
      end
    end
  end
end
