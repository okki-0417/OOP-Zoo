# frozen_string_literal: true

class Spectacle
  SATURATION = 3_000

  def initialize(on_exhibit:)
    @on_exhibit = on_exhibit
  end

  def value
    saturate(charisma_total)
  end

  private

  def charisma_total
    @on_exhibit.map(&:species).uniq.sum(&:charisma)
  end

  def saturate(standing)
    SATURATION * standing / (standing + SATURATION).to_f
  end
end
