# frozen_string_literal: true

module Zoo
  module Domain
    class EnclosureDay
      ENRICHMENT_DECAY_PER_DAY = 2

      def initialize(enclosure, occupancy, season: Season.spring)
        @enclosure = enclosure
        @occupancy = occupancy
        @infestation = Infestation.new(enclosure, occupancy)
        @contagion = Contagion.new(enclosure, occupancy)
        @animal_days = occupancy.map do |animal|
          AnimalDay.new(animal: animal, enclosure: enclosure, occupancy: occupancy, season: season)
        end
      end

      def run
        @infestation.spread
        @contagion.spread
        @animal_days.each(&:run)
        @enclosure.soil(@occupancy.count)
        @enclosure.deplete_enrichment(ENRICHMENT_DECAY_PER_DAY)
        @occupancy.select(&:dead?)
      end
    end
  end
end
