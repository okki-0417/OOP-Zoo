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
        errors.concat(@occupancy.species_present_in.filter_map { |resident| cohabitation_conflict(resident) })

        raise Errors::HousingNotAllowed, errors.join(', ') unless errors.empty?
      end

      def to_s
        "#{@animal.name}を収容"
      end

      private

      def cohabitation_conflict(resident)
        newcomer = @animal.species

        if !climate_overlaps?(newcomer, resident)
          "#{newcomer.name_ja}と#{resident.name_ja}は適温域が両立しません"
        elsif newcomer == resident
          "#{newcomer.name_ja}は単独性のため同種を同居させられません" if newcomer.solitary?
        elsif newcomer.predatory? || resident.predatory?
          "#{newcomer.name_ja}と#{resident.name_ja}は捕食関係の恐れがあり同居させられません"
        end
      end

      def climate_overlaps?(species_a, species_b)
        low = [species_a.habitable_temperature_range.begin, species_b.habitable_temperature_range.begin].max
        high = [species_a.habitable_temperature_range.end, species_b.habitable_temperature_range.end].min
        low <= high
      end
    end
  end
end
