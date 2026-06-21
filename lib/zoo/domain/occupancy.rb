# frozen_string_literal: true

module Zoo
  module Domain
    class Occupancy
      SOCIAL_CONFLICT_INJURY = 5

      CROWDING_AGGRAVATION = 5

      NO_REFUGE_AGGRAVATION = 5

      def initialize(events = [])
        @current = {}
        events.each do |event|
          case event
          when Release then withdraw(event)
          when Housing then @current[event.animal.id.to_s] = event
          end
        end
      end

      def occupants_of(enclosure)
        id = enclosure.id.to_s
        @current.values
                .select { |housing| housing.enclosure_id.to_s == id && housing.animal.alive? }
                .map(&:animal)
      end

      def all_occupants
        @current.values.filter_map { |housing| housing.animal if housing.animal.alive? }
      end

      def houses?(enclosure, animal)
        occupants_of(enclosure).include?(animal)
      end

      def current_housing_of(animal)
        @current[animal.id.to_s]
      end

      def enclosure_id_of(animal)
        current_housing_of(animal)&.enclosure_id
      end

      def population_of(enclosure)
        occupants_of(enclosure).size
      end

      def vacancies_in(enclosure)
        enclosure.capacity - population_of(enclosure)
      end

      def full?(enclosure)
        vacancies_in(enclosure) <= 0
      end

      def empty?(enclosure)
        occupants_of(enclosure).empty?
      end

      def species_present_in(enclosure)
        self.class.species_present(occupants_of(enclosure))
      end

      def required_area_of(enclosure)
        self.class.required_area(occupants_of(enclosure))
      end

      def overcrowded?(enclosure)
        self.class.overcrowded?(enclosure, occupants_of(enclosure))
      end

      def subordinate_male?(enclosure, animal)
        self.class.subordinate_male?(occupants_of(enclosure), animal)
      end

      def injury_for(enclosure, animal)
        self.class.injury_for(enclosure, occupants_of(enclosure), animal)
      end

      def admission_violation(enclosure, animal)
        return Errors::DeadAnimal.new("#{animal.name}は死亡しているため収容できません") if animal.dead?

        return Errors::CapacityExceeded.new("#{enclosure.name}は定員#{enclosure.capacity}に達しています") if full?(enclosure)

        unless animal.species.habitable?(enclosure.temperature)
          return Errors::ClimateMismatch.new(
            "#{animal.species.name_ja}は#{enclosure.temperature}の#{enclosure.name}に適応できません"
          )
        end

        species_present_in(enclosure).each do |resident_species|
          reason = resident_species.cohabitation_conflict_with(animal.species)
          return Errors::IncompatibleCohabitation.new(reason) if reason
        end

        nil
      end

      def can_admit?(enclosure, animal)
        admission_violation(enclosure, animal).nil?
      end

      def rejection_reason(enclosure, animal)
        admission_violation(enclosure, animal)&.message
      end

      def self.species_present(occupants)
        occupants.map(&:species).uniq
      end

      def self.required_area(occupants)
        occupants.sum { |animal| animal.species.space_requirement_sqm }
      end

      def self.overcrowded?(enclosure, occupants)
        required_area(occupants) > enclosure.area_sqm
      end

      def self.subordinate_male?(occupants, animal)
        return false unless contender?(animal)

        rivals = occupants.select { |other| contender?(other) && other.species.same_species?(animal.species) }
        return false if rivals.size < 2

        animal.id != rivals.max_by(&:age_in_days).id
      end

      def self.injury_for(enclosure, occupants, animal)
        return 0 unless subordinate_male?(occupants, animal)

        injury = SOCIAL_CONFLICT_INJURY
        injury += CROWDING_AGGRAVATION if overcrowded?(enclosure, occupants)
        injury += NO_REFUGE_AGGRAVATION if enclosure.barren?
        injury
      end

      def self.contender?(animal)
        animal.alive? && animal.male? && animal.mature? && animal.species.group_living?
      end

      private

      def withdraw(release)
        key = release.animal.id.to_s
        @current.delete(key) if @current[key]&.id == release.housing.id
      end
    end
  end
end
