# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Examination < BaseObject
          field :animal, Animal, null: false
          field :diagnosis, Diagnosis, null: false
        end
      end
    end
  end
end
