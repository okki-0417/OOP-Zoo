# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class SkippedWork < BaseObject
          field :subject, String, null: false
          field :reason, String, null: false
        end
      end
    end
  end
end
