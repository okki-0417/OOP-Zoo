# frozen_string_literal: true

module Types
  class Herd < BaseObject
    field :enclosure, Enclosure, null: false
    field :species, Species, null: false
    field :size, Integer, null: false
    field :crowded, Boolean, null: false, method: :crowded?
    field :multiplier, Float, null: false
    field :bonus, Integer, null: false

    def multiplier
      object.multiplier.round(2)
    end

    def bonus
      object.bonus.round
    end
  end
end
