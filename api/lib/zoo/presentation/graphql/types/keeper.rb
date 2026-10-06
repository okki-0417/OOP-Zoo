# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Keeper < BaseObject
          field :id, ID, null: false
          field :name, String, null: false
          field :specialties, [TaxonClass], null: false
          field :worked_minutes, Integer, null: false
          field :remaining_minutes, Integer, null: false
          field :enclosures, [Enclosure], null: false

          def enclosures
            container.assignments.enclosures_of(object)
          end
        end
      end
    end
  end
end
