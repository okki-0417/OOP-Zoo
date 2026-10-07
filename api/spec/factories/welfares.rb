# frozen_string_literal: true

FactoryBot.define do
  factory :welfare do
    skip_create

    transient do
      animal { association :animal, strategy: :build }
      enclosure { association :enclosure, strategy: :build }
      occupants { [animal] }
      season { Season.spring }
      occupancy { Occupancy.new(enclosure:, occupants:) }
    end

    initialize_with do
      new(
        animal:, enclosure:, occupancy:,
        companionship: Companionship.new(enclosure:, occupancy:, member: animal),
        thermal_suitability: ThermalSuitability.new(animal, enclosure.effective_temperature(season))
      )
    end
  end
end
