# frozen_string_literal: true

module Types
  class Rounds < BaseObject
    field :keeper, Keeper, null: false
    field :reports, [RoundReport], null: false
  end
end
