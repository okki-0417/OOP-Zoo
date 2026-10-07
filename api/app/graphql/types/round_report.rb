# frozen_string_literal: true

module Types
  class RoundReport < BaseObject
    field :enclosure, Enclosure, null: false
    field :fed, [Animal], null: false
    field :skipped, [SkippedWork], null: false
    field :cleaned, Boolean, null: false, method: :cleaned?
    field :enriched, Boolean, null: false, method: :enriched?

    def skipped
      object.skipped.map { |subject, reason| { subject:, reason: } }
    end
  end
end
