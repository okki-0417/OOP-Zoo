# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Rounds < BaseObject
          field :keeper, Keeper, null: false
          field :reports, [RoundReport], null: false
        end
      end
    end
  end
end
