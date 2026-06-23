# frozen_string_literal: true

module Zoo
  module Domain
    class EnclosureDay
      ENRICHMENT_DECAY_PER_DAY = 2

      def initialize(enclosure, occupants, season: Season.spring)
        @enclosure = enclosure
        @occupants = occupants
        @season = season
      end

      def run
        spread_disease_if_filthy
        Contagion.new(Occupancy.new(@enclosure, @occupants)).spread
        @occupants.each do |animal|
          next if animal.dead?

          apply_welfare(animal)
          animal.injure(SocialConflict.new(@enclosure, @occupants, animal).injury)
          animal.grow_older(1) unless animal.dead?
        end
        @enclosure.soil(@occupants.size)
        @enclosure.deplete_enrichment(ENRICHMENT_DECAY_PER_DAY)
        @occupants.select(&:dead?)
      end

      private

      def apply_welfare(animal)
        delta = Welfare.daily_stress(animal, @enclosure, @occupants, season: @season)
        delta.negative? ? animal.relieve_stress(-delta) : animal.add_stress(delta)
      end

      def spread_disease_if_filthy
        return unless @enclosure.filthy?

        @occupants.each do |animal|
          animal.fall_ill(IllnessCatalog.parasite) if animal.susceptible?
        end
      end
    end
  end
end
