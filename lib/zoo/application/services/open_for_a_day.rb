# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class OpenForADay
        def initialize(enclosures:, animals:, housings:, event_dispatcher:, unit_of_work:)
          @enclosures = enclosures
          @animals = animals
          @housings = housings
          @event_dispatcher = event_dispatcher
          @unit_of_work = unit_of_work
        end

        def call(season: Domain::Season.spring)
          deceased = []
          occupancy = Domain::Occupancy.new(@housings.all)

          @enclosures.all.each do |enclosure|
            occupants = occupancy.occupants_of(enclosure)

            dead, events = @unit_of_work.run do
              dead_animals = Domain::EnclosureDay.new(enclosure, occupants, season: season).run
              @enclosures.save(enclosure)
              occupants.each { |animal| @animals.save(animal) }
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
