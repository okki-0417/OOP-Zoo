# frozen_string_literal: true

module Types
  class Blemish < BaseObject
    field :cause, BlemishCause, null: false
    field :penalty, Integer, null: false
  end
end
