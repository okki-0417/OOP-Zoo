# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      EnclosureProfile = Data.define(
        :id, :name, :celsius, :climate_controlled, :capacity, :population, :cleanliness, :filthy, :enrichment, :barren, :keepers, :occupants
      ) do
        def self.of(enclosure, occupants:, keepers:)
          new(
            id: enclosure.id.to_s,
            name: enclosure.name,
            celsius: enclosure.temperature.celsius,
            climate_controlled: enclosure.climate_controlled?,
            capacity: enclosure.capacity,
            population: occupants.size,
            cleanliness: enclosure.cleanliness_level,
            filthy: enclosure.filthy?,
            enrichment: enclosure.enrichment.level,
            barren: enclosure.barren?,
            keepers: keepers.map { |keeper| StaffRef.of(keeper) },
            occupants: occupants.map { |animal| AnimalSummary.of(animal) }
          )
        end

        def self.housed(enclosure, housings:, assignments:)
          of(enclosure, occupants: housings.occupants_of(enclosure), keepers: assignments.keepers_of(enclosure))
        end
      end
    end
  end
end
