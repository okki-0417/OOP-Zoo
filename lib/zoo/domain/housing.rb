# frozen_string_literal: true

module Zoo
  module Domain
    class Housing
      include Shared::Entity

      attr_reader :id, :animal, :enclosure, :occurred_on, :keeper_id

      def initialize(animal:, enclosure:, occupancy: nil, occurred_on: 0, keeper_id: nil, id: Shared::Identifier.new)
        @id = id
        @animal = animal
        @enclosure = enclosure
        @occupancy = occupancy
        @occurred_on = occurred_on
        @keeper_id = keeper_id
        freeze
      end

      def enclosure_id
        @enclosure.id
      end

      def admission_violation!
        errors = []
        errors << "#{@animal.name}は死亡しているため収容できません" if @animal.dead?
        errors << "#{@enclosure.name}は定員#{@enclosure.capacity}に達しています" if @occupancy.full?
        unless ThermalSuitability.new(@animal, @enclosure.temperature).habitable?
          errors << "#{@animal.species_name}は#{@enclosure.temperature}の#{@enclosure.name}に適応できません"
        end

        errors.concat(cohabitation_conflicts)

        raise Errors::HousingNotAllowed, errors.join(', ') unless errors.empty?
      end

      def to_s
        "#{@animal.name}を収容"
      end

      private

      def cohabitation_conflicts
        @occupancy.species_present_in.filter_map do |resident_species|
          @animal.cohabitation_conflict_with(resident_species)
        end
      end
    end
  end
end
