# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class TaxonClass < BaseObject
          field :code, String, null: false
          field :label, String, null: false

          def code
            object.value.to_s
          end
        end
      end
    end
  end
end
