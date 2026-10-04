# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      EnclosureProfile = Data.define(:id, :name, :capacity, :population, :cleanliness, :filthy, :occupants) do
        def self.of(enclosure, occupants:)
          new(
            id: enclosure.id.to_s,
            name: enclosure.name,
            capacity: enclosure.capacity,
            population: occupants.size,
            cleanliness: enclosure.cleanliness_level,
            filthy: enclosure.filthy?,
            occupants: occupants.map { |animal| AnimalSummary.of(animal) }
          )
        end

        def self.housed(enclosure, housings:)
          of(enclosure, occupants: housings.occupants_of(enclosure))
        end
      end
    end
  end
end
