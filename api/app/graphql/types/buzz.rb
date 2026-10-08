# frozen_string_literal: true

module Types
  class Buzz < BaseObject
    field :animal, Animal, null: false
    field :kind, BuzzKind, null: false
    field :amount, Integer, null: false

    def amount
      object.amount.round
    end
  end
end
