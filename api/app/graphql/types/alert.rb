# frozen_string_literal: true

module Types
  class Alert < BaseObject
    field :severity, AlertSeverity, null: false
    field :kind, AlertKind, null: false
    field :subject_type, AlertSubject, null: false
    field :subject_id, ID
    field :subject_name, String, null: false
    field :message, String, null: false

    def subject_id
      object[:subject_type] == :zoo ? nil : object[:subject].id
    end

    def subject_name
      object[:subject].name
    end
  end
end
