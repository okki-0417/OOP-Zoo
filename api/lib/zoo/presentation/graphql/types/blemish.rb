# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Blemish < BaseObject
          field :cause, BlemishCause, null: false
          field :penalty, Integer, null: false
        end
      end
    end
  end
end
