# frozen_string_literal: true

module Zoo
  module Domain
    class Enclosure
      include Shared::Entity

      attr_reader :id, :name, :temperature, :capacity, :cleanliness, :enrichment

      AREA_PER_SLOT_SQM = 100

      ENRICHMENT_DECAY_PER_DAY = 2

      SOCIAL_CONFLICT_INJURY = 5

      CROWDING_AGGRAVATION = 5

      NO_REFUGE_AGGRAVATION = 5

      def initialize(name:, temperature:, capacity:, area_sqm: nil, climate_controlled: false,
                     id: Shared::Identifier.new)
        raise ArgumentError, 'エリア名は必須です' if name.to_s.empty?
        raise ArgumentError, '定員は1以上でなければなりません' unless capacity.is_a?(Integer) && capacity.positive?

        @id = id
        @name = name
        @temperature = temperature
        @capacity = capacity
        @area_sqm = area_sqm
        @climate_controlled = climate_controlled
        @cleanliness = Cleanliness.spotless
        @enrichment = Enrichment.stimulating
        @occupants = []
      end

      def climate_controlled?
        @climate_controlled
      end

      def effective_temperature(season)
        return @temperature if climate_controlled?

        season.felt_temperature(@temperature)
      end

      def self.reconstitute(id:, name:, temperature:, capacity:, cleanliness:, occupants:)
        allocate.tap do |enclosure|
          enclosure.instance_variable_set(:@id, id)
          enclosure.instance_variable_set(:@name, name)
          enclosure.instance_variable_set(:@temperature, temperature)
          enclosure.instance_variable_set(:@capacity, capacity)
          enclosure.instance_variable_set(:@area_sqm, nil)
          enclosure.instance_variable_set(:@cleanliness, cleanliness)
          enclosure.instance_variable_set(:@enrichment, Enrichment.stimulating)
          enclosure.instance_variable_set(:@occupants, occupants)
        end
      end

      def admit(animal)
        violation = violation_for(animal)
        raise violation if violation

        @occupants << animal
        self
      end

      def can_admit?(animal)
        violation_for(animal).nil?
      end

      def rejection_reason(animal)
        violation_for(animal)&.message
      end

      def release(animal)
        @occupants.delete(animal)
        self
      end

      def occupants
        @occupants.dup
      end

      def population
        @occupants.size
      end

      def area_sqm
        @area_sqm || (capacity * AREA_PER_SLOT_SQM)
      end

      def required_area
        @occupants.sum { |animal| animal.species.space_requirement_sqm }
      end

      def overcrowded?
        required_area > area_sqm
      end

      def vacancies
        @capacity - population
      end

      def full?
        vacancies <= 0
      end

      def empty?
        @occupants.empty?
      end

      def houses?(animal)
        @occupants.include?(animal)
      end

      def species_present
        @occupants.map(&:species).uniq
      end

      def clean(amount = 100)
        @cleanliness = @cleanliness.cleaned_by(amount)
        self
      end

      def soil(amount)
        @cleanliness = @cleanliness.soiled_by(amount)
        self
      end

      def filthy?
        @cleanliness.filthy?
      end

      def enrich(amount = 100)
        @enrichment = @enrichment.enriched_by(amount)
        self
      end

      def deplete_enrichment(amount)
        @enrichment = @enrichment.depleted_by(amount)
        self
      end

      def barren?
        @enrichment.barren?
      end

      def subordinate_male?(animal)
        return false unless contender?(animal)

        rivals = @occupants.select { |other| contender?(other) && other.species.same_species?(animal.species) }
        return false if rivals.size < 2

        animal.id != rivals.max_by { |male| male.age_in_days.value }.id
      end

      def injury_for(animal)
        return 0 unless subordinate_male?(animal)

        injury = SOCIAL_CONFLICT_INJURY
        injury += CROWDING_AGGRAVATION if overcrowded?
        injury += NO_REFUGE_AGGRAVATION if barren?
        injury
      end

      def pass_day(season: Season.spring)
        spread_disease_if_filthy
        Contagion.spread(self)
        @occupants.each do |animal|
          next if animal.dead?

          apply_welfare(animal, season)
          animal.injure(injury_for(animal))
          animal.grow_older(1) unless animal.dead?
        end
        soil(@occupants.size)
        deplete_enrichment(ENRICHMENT_DECAY_PER_DAY)
        dead = @occupants.select(&:dead?)
        dead.each { |a| @occupants.delete(a) }
        dead
      end

      private

      def apply_welfare(animal, season)
        delta = Welfare.daily_stress(animal, self, season: season)
        delta.negative? ? animal.relieve_stress(-delta) : animal.add_stress(delta)
      end

      def contender?(animal)
        animal.alive? && animal.sex.male? && animal.mature? && animal.species.group_living?
      end

      def spread_disease_if_filthy
        return unless filthy?

        @occupants.each do |animal|
          animal.fall_ill(IllnessCatalog.parasite) if animal.alive? && !animal.sick?
        end
      end

      def violation_for(animal)
        return Errors::DeadAnimal.new("#{animal.name}は死亡しているため収容できません") if animal.dead?

        return Errors::CapacityExceeded.new("#{@name}は定員#{@capacity}に達しています") if full?

        unless animal.species.habitable?(@temperature)
          return Errors::ClimateMismatch.new(
            "#{animal.species.name_ja}は#{@temperature}の#{@name}に適応できません"
          )
        end

        species_present.each do |resident|
          reason = resident.cohabitation_conflict_with(animal.species)
          return Errors::IncompatibleCohabitation.new(reason) if reason
        end

        nil
      end
    end
  end
end
