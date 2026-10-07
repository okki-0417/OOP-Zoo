# frozen_string_literal: true

module Types
  class Stressor < BaseObject
    field :cause, StressorCause, null: false
    field :amount, Integer, null: false
  end
end
