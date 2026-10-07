# frozen_string_literal: true

module Types
  class Occupancy < BaseObject
    field :full, Boolean, null: false, method: :full?
    field :overcrowded, Boolean, null: false, method: :overcrowded?
  end
end
