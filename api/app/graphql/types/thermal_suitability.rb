# frozen_string_literal: true

module Types
  class ThermalSuitability < BaseObject
    field :habitable, Boolean, null: false, method: :habitable?
    field :comfortable, Boolean, null: false, method: :comfortable?
  end
end
