# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Veterinarian < BaseObject
          field :id, ID, null: false
          field :name, String, null: false
        end
      end
    end
  end
end
