# frozen_string_literal: true

module Zoo
  module Domain
    class SocialConflict
      SOCIAL_CONFLICT_INJURY = 5
      CROWDING_AGGRAVATION = 5
      NO_REFUGE_AGGRAVATION = 5

      def initialize(enclosure, occupants, animal)
        @enclosure = enclosure
        @occupants = occupants
        @animal = animal
      end

      def subordinate_male?
        return false unless @animal.contender?

        rivals = @occupants.select { |other| other.contender? && other.species == @animal.species }
        return false if rivals.size < 2

        @animal.id != rivals.max_by(&:age_in_days).id
      end

      def injury
        return 0 unless subordinate_male?

        injury = SOCIAL_CONFLICT_INJURY
        injury += CROWDING_AGGRAVATION if Occupancy.new(@enclosure, @occupants).overcrowded?
        injury += NO_REFUGE_AGGRAVATION if @enclosure.barren?
        injury
      end
    end
  end
end
