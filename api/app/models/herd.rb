# frozen_string_literal: true

class Herd
  BONUS_LIMIT = 0.5
  BONUS_DECAY = 0.5

  attr_reader :enclosure, :species, :size

  def self.in(occupancy)
    occupancy.group_by(&:species).map do |species, members|
      new(enclosure: occupancy.enclosure, species:, size: members.size, crowded: occupancy.overcrowded?)
    end
  end

  def initialize(enclosure:, species:, size:, crowded:)
    @enclosure = enclosure
    @species = species
    @size = size
    @crowded = crowded
  end

  def crowded?
    @crowded
  end

  def multiplier
    return 1.0 if @species.solitary? || @crowded

    1 + (BONUS_LIMIT * (1 - (BONUS_DECAY**(@size - 1))))
  end

  def appeal
    @species.charisma * multiplier
  end

  def bonus
    appeal - @species.charisma
  end
end
