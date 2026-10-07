# frozen_string_literal: true

module Types
  class SkippedWork < BaseObject
    field :subject, String, null: false
    field :reason, String, null: false
  end
end
