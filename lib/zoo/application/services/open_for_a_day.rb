# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class OpenForADay
        def initialize(enclosures:, animals:, housings:, unit_of_work:)
          @enclosures = enclosures
          @animals = animals
          @housings = housings
          @unit_of_work = unit_of_work
        end

        def call(season: Domain::Season.spring)
          deceased = []

          @housings.all_occupancies.each do |occupancy|
            enclosure = occupancy.enclosure

            dead = @unit_of_work.run do
              Domain::Infestation.new(enclosure, occupancy).spread
              Domain::Contagion.new(enclosure, occupancy).spread
              occupancy.each do |animal|
                Domain::AnimalDay.new(animal:, enclosure:, occupancy:, season:).run
              end
              enclosure.soil(occupancy.count)
              enclosure.deplete_enrichment

              dead_animals = occupancy.select(&:dead?)
              @enclosures.save(enclosure)
              occupancy.each { |animal| @animals.save(animal) }
              dead_animals
            end

            deceased.concat(dead)
          end

          deceased
        end
      end
    end
  end
end
