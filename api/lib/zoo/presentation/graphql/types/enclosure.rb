# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Enclosure < BaseObject
          field :id, ID, null: false
          field :name, String, null: false
          field :celsius, Float, null: false
          field :climate_controlled, Boolean, null: false, method: :climate_controlled?
          field :capacity, Integer, null: false
          field :cleanliness, Integer, null: false, method: :cleanliness_level
          field :filthy, Boolean, null: false, method: :filthy?
          field :soiled, Boolean, null: false, method: :soiled?
          field :enrichment, Integer, null: false
          field :barren, Boolean, null: false, method: :barren?
          field :dull, Boolean, null: false, method: :dull?
          field :occupants, [Animal], null: false
          field :keepers, [Keeper], null: false
          field :occupancy, Occupancy, null: false

          def celsius
            object.temperature.celsius
          end

          def enrichment
            object.enrichment.level
          end

          def occupants
            container.housings.occupants_of(object)
          end

          def keepers
            container.assignments.keepers_of(object)
          end

          def occupancy
            occupancy_of(object)
          end
        end
      end
    end
  end
end
