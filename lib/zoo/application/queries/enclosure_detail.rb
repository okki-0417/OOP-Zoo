# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class EnclosureDetail
        def initialize(enclosures:)
          @enclosures = enclosures
        end

        def call(enclosure_id)
          enclosure = @enclosures.find(enclosure_id)
          return nil if enclosure.nil?

          ReadModels::EnclosureProfile.new(
            id: enclosure.id.to_s,
            name: enclosure.name,
            capacity: enclosure.capacity,
            population: enclosure.population,
            cleanliness: enclosure.cleanliness.level,
            filthy: enclosure.filthy?,
            occupants: enclosure.occupants.map { |animal| occupant(animal) }
          )
        end

        private

        def occupant(animal)
          ReadModels::AnimalSummary.new(
            id: animal.id.to_s, name: animal.name.to_s, species: animal.species.name_ja, alive: animal.alive?,
            health: animal.health.current, max_health: animal.health.max,
            ailing: animal.alive? && (animal.sick? || animal.starving? || animal.health.weak?)
          )
        end
      end
    end
  end
end
