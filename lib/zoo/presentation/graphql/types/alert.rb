# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Alert < BaseObject
          field :severity, String, null: false
          field :kind, String, null: false
          field :subject_type, String, null: false
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
    end
  end
end
