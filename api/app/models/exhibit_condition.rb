# frozen_string_literal: true

class ExhibitCondition
  NEUTRAL = 50

  def initialize(animals)
    @animals = animals
  end

  def score
    living = @animals.select(&:alive?)
    return NEUTRAL if living.empty?

    living.sum(&:visible_condition) / living.size
  end
end
