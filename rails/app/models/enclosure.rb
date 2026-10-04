# frozen_string_literal: true

class Enclosure < ApplicationRecord
  AREA_PER_SLOT_SQM = 100
  ENRICHMENT_DECAY_PER_DAY = 2

  CONSTRUCTION_BASE_YEN = 30_000
  CONSTRUCTION_PER_SLOT_YEN = 10_000
  CLIMATE_CONTROL_SURCHARGE_YEN = 50_000

  UPKEEP_YEN = 5_000
  CLIMATE_CONTROL_RUNNING_YEN = 4_000

  validates :name, presence: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }

  def self.construction_cost(capacity:, climate_controlled: false)
    yen = CONSTRUCTION_BASE_YEN + (CONSTRUCTION_PER_SLOT_YEN * capacity)
    yen += CLIMATE_CONTROL_SURCHARGE_YEN if climate_controlled
    Money.yen(yen)
  end

  def self.build(name:, temperature:, capacity:, area_sqm: nil, climate_controlled: false)
    create!(
      name: name.to_s, celsius: temperature.celsius, capacity: capacity,
      area_sqm: area_sqm, climate_controlled: climate_controlled
    )
  end

  def temperature
    Temperature.celsius(celsius)
  end

  def climate_controlled?
    climate_controlled
  end

  def daily_upkeep
    Money.yen(UPKEEP_YEN + (climate_controlled? ? CLIMATE_CONTROL_RUNNING_YEN : 0))
  end

  def area_sqm
    super || (capacity * AREA_PER_SLOT_SQM)
  end

  def clean(amount = 100)
    write_cleanliness(cleanliness_vo.cleaned_by(amount))
    self
  end

  def soil(amount)
    write_cleanliness(cleanliness_vo.soiled_by(amount))
    self
  end

  def filthy?
    cleanliness_vo.filthy?
  end

  def cleanliness_level
    cleanliness
  end

  def enrich(amount = 100)
    write_enrichment(enrichment_vo.enriched_by(amount))
    self
  end

  def deplete_enrichment(amount = ENRICHMENT_DECAY_PER_DAY)
    write_enrichment(enrichment_vo.depleted_by(amount))
    self
  end

  def barren?
    enrichment_vo.barren?
  end

  def as_json(*)
    occupants = Housing.occupants_of(self)
    {
      id: id, name: name, capacity: capacity, population: occupants.size,
      cleanliness: cleanliness, filthy: filthy?,
      occupants: occupants.map(&:summary_json)
    }
  end

  def summary_json
    {
      id: id, name: name, population: Housing.occupants_of(self).size,
      capacity: capacity, cleanliness: cleanliness, filthy: filthy?
    }
  end

  private

  def cleanliness_vo
    Cleanliness.new(cleanliness)
  end

  def write_cleanliness(new_cleanliness)
    self.cleanliness = new_cleanliness.level
  end

  def enrichment_vo
    Enrichment.new(enrichment)
  end

  def write_enrichment(new_enrichment)
    self.enrichment = new_enrichment.level
  end
end
