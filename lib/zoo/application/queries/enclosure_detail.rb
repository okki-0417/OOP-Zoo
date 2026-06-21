# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class EnclosureDetail
        def initialize(enclosures:, housings:)
          @enclosures = enclosures
          @housings = housings
        end

        def call(enclosure_id)
          enclosure = @enclosures.find(enclosure_id)
          return nil if enclosure.nil?

          occupancy = Domain::Occupancy.new(@housings.all)
          ReadModels::EnclosureProfile.new(
            id: enclosure.id.to_s,
            name: enclosure.name,
            capacity: enclosure.capacity,
            population: occupancy.population_of(enclosure),
            cleanliness: enclosure.cleanliness.level,
            filthy: enclosure.filthy?,
            occupants: occupancy.occupants_of(enclosure).map { |animal| occupant(animal) }
          )
        end

        private

        def occupant(animal)
          ReadModels::AnimalSummary.new(
            id: animal.id.to_s, name: animal.name, species: animal.species.name_ja, alive: animal.alive?,
            health: animal.current_health, max_health: animal.max_health,
            ailing: animal.alive? && (animal.sick? || animal.starving? || animal.weak?)
          )
        end
      end
    end
  end
end
