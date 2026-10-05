# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Species < BaseObject
          field :code, String, null: false
          field :name_ja, String, null: false
          field :taxon_class, TaxonClass, null: false
          field :diet, String, null: false, method: :diet_label
          field :conservation_code, String, null: false
          field :conservation_label, String, null: false
          field :threatened, Boolean, null: false, method: :threatened?
          field :charisma, Integer, null: false

          def code
            Domain::SpeciesCatalog.keys.find { |key| Domain::SpeciesCatalog.find(key) == object }.to_s
          end
        end
      end
    end
  end
end
