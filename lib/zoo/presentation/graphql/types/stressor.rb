# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Stressor < BaseObject
          field :cause, StressorCause, null: false
          field :amount, Integer, null: false
        end
      end
    end
  end
end
