# frozen_string_literal: true

class Spectacle
  SATURATION = 3_000

  def self.of(occupancies, today:)
    new(
      herds: occupancies.flat_map { |occupancy| Herd.in(occupancy) },
      buzzes: occupancies.flat_map(&:to_a).map { |animal| Buzz.new(animal:, today:) }.select(&:kind)
    )
  end

  attr_reader :buzzes

  def initialize(herds:, buzzes:)
    @herds = herds
    @buzzes = buzzes
  end

  def value
    saturate(charisma + herd_bonus + buzz)
  end

  def herds
    @herds.group_by(&:species).map { |_species, herds| herds.max_by(&:appeal) }
  end

  def charisma
    herds.sum { |herd| herd.species.charisma }
  end

  def herd_bonus
    herds.sum(&:bonus)
  end

  def buzz
    @buzzes.sum(&:amount)
  end

  private

  def saturate(standing)
    SATURATION * standing / (standing + SATURATION).to_f
  end
end
