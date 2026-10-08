# frozen_string_literal: true

class Alert
  SEVERITIES = %i[critical warning notice].freeze

  def self.all
    new(
      zoo: Zoo.current,
      occupancies: Occupancy.all,
      keepers: Keeper.all.to_a,
      veterinarians: Veterinarian.all.to_a,
      unhoused: Animal.alive.where(enclosure: nil).to_a
    ).to_a
  end

  def initialize(zoo:, occupancies:, keepers:, veterinarians:, unhoused:)
    @zoo = zoo
    @occupancies = occupancies
    @keepers = keepers
    @veterinarians = veterinarians
    @unhoused = unhoused
  end

  def to_a
    [
      *zoo_alerts,
      *StaffingAlerts.new(zoo: @zoo, occupants:, keepers: @keepers, veterinarians: @veterinarians).to_a,
      *@occupancies.flat_map do |occupancy|
        EnclosureAlerts.new(occupancy:, keepers: occupancy.enclosure.keepers.to_a).to_a
      end,
      *@occupancies.flat_map { |occupancy| housed_animal_alerts(occupancy) },
      *unhoused_alerts
    ].sort_by { |alert| rank(alert) }
  end

  private

  def occupants
    @occupancies.flat_map(&:to_a).select(&:alive?)
  end

  def zoo_alerts
    return [] unless @zoo.balance.negative?

    [{ severity: :critical, kind: :insolvent, subject_type: :zoo, subject: @zoo,
       message: "資金が赤字です(残高 #{@zoo.balance})" }]
  end

  def rank(alert)
    [SEVERITIES.index(alert[:severity]), alert[:subject_type] == :zoo ? 0 : 1, alert[:subject].name.to_s]
  end

  def housed_animal_alerts(occupancy)
    occupancy.select(&:alive?).flat_map { |animal| AnimalAlerts.new(animal:, occupancy:, season: @zoo.season).to_a }
  end

  def unhoused_alerts
    @unhoused.map do |animal|
      { severity: :warning, kind: :unhoused, subject_type: :animal, subject: animal,
        message: 'どのエリアにも収容されていません' }
    end
  end
end
