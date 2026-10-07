# frozen_string_literal: true

module Types
  class RunDaysSummary < BaseObject
    field :days, Integer, null: false
    field :total_deaths, Integer, null: false
  end
end
