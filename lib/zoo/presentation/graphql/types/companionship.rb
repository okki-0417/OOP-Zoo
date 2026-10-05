# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Companionship < BaseObject
          field :lonely, Boolean, null: false, method: :lonely?
          field :separated_dependent, Boolean, null: false, method: :separated_dependent?
          field :subordinate_male, Boolean, null: false, method: :subordinate_male?
        end
      end
    end
  end
end
