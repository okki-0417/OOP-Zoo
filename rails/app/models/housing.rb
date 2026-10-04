# frozen_string_literal: true

class Housing < HousingEvent
  belongs_to :animal
  belongs_to :enclosure
  private :animal=, :enclosure=

  attr_writer :occupancy
  private :occupancy=

  def self.house(animal:, enclosure:, occupancy:, occurred_on: 0, keeper_id: nil)
    housing = new(occurred_on: occurred_on, keeper_id: keeper_id)
    housing.send(:animal=, animal)
    housing.send(:enclosure=, enclosure)
    housing.send(:occupancy=, occupancy)
    housing.admission_violation!
    housing.save!
    housing
  end

  def self.current_all
    where.not(id: closed_ids).where(id: latest_ids_per_animal)
  end

  def self.current_for(animal)
    current_all.find_by(animal_id: animal.id)
  end

  def self.current_for_enclosure(enclosure)
    current_all.where(enclosure_id: enclosure.id).includes(:animal, :enclosure)
  end

  def self.occupants_of(enclosure)
    current_for_enclosure(enclosure).filter_map { |housing| housing.animal if housing.animal.alive? }
  end

  def self.all_occupants
    current_all.includes(:animal).filter_map { |housing| housing.animal if housing.animal.alive? }
  end

  def self.all_occupancies
    current_all.includes(:animal, :enclosure)
               .select { |housing| housing.animal.alive? }
               .group_by(&:enclosure)
               .map { |enclosure, housings| Occupancy.new(housings: housings, enclosure: enclosure) }
  end

  def self.closed_ids
    Releasing.where.not(closes_housing_id: nil).select(:closes_housing_id)
  end
  private_class_method :closed_ids

  def self.latest_ids_per_animal
    where.not(id: closed_ids).group(:animal_id).maximum(:id).values
  end
  private_class_method :latest_ids_per_animal

  def admission_violation!
    errors = []
    errors << "#{animal.name}は死亡しているため収容できません" if animal.dead?
    errors << "#{enclosure.name}は定員#{enclosure.capacity}に達しています" if @occupancy.full?
    unless ThermalSuitability.new(animal: animal, temperature: enclosure.temperature).habitable?
      errors << "#{animal.species_name}は#{enclosure.temperature}の#{enclosure.name}に適応できません"
    end
    errors.concat(@occupancy.species_present_in.filter_map { |resident| cohabitation_conflict(resident) })

    raise Errors::HousingNotAllowed, errors.join(', ') unless errors.empty?
  end

  def to_s
    "#{animal.name}を収容"
  end

  private

  def cohabitation_conflict(resident)
    newcomer = animal.species

    if !newcomer.climate_overlaps?(resident)
      "#{newcomer.name_ja}と#{resident.name_ja}は適温域が両立しません"
    elsif newcomer == resident
      "#{newcomer.name_ja}は単独性のため同種を同居させられません" if newcomer.solitary?
    elsif newcomer.predatory? || resident.predatory?
      "#{newcomer.name_ja}と#{resident.name_ja}は捕食関係の恐れがあり同居させられません"
    end
  end
end
