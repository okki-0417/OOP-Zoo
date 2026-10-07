# frozen_string_literal: true

class Housing
  attr_reader :animal, :enclosure

  def initialize(animal:, enclosure:, occupancy:)
    @animal = animal
    @enclosure = enclosure
    @occupancy = occupancy
    freeze
  end

  def perform
    admission_violation!
    @animal.move_to(@enclosure)
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

    if !newcomer.climate_overlaps?(resident)
      "#{newcomer.name_ja}と#{resident.name_ja}は適温域が両立しません"
    elsif newcomer == resident
      "#{newcomer.name_ja}は単独性のため同種を同居させられません" if newcomer.solitary?
    elsif newcomer.predatory? || resident.predatory?
      "#{newcomer.name_ja}と#{resident.name_ja}は捕食関係の恐れがあり同居させられません"
    end
  end
end
