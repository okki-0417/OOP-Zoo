# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class OpenForADay
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:open_for_a_day) do
            @command.housings.all_occupancies.flat_map do |occupancy|
              enclosure = occupancy.enclosure

              @command.unit_of_work.run do
                Domain::Infestation.new(enclosure, occupancy).spread
                Domain::Contagion.new(enclosure, occupancy).spread
                occupancy.each do |animal|
                  Domain::AnimalDay.new(animal:, enclosure:, occupancy:, season: @command.season).run
                end
                enclosure.soil(occupancy.count)
                enclosure.deplete_enrichment

                dead_animals = occupancy.select(&:dead?)
                @command.enclosures.save(enclosure)
                occupancy.each { |animal| @command.animals.save(animal) }
                dead_animals
              end
            end
          end
        end
      end
    end
  end
end
