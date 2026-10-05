# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Mutations
        class HireKeeper < BaseMutation
          type Types::Keeper, null: false

          argument :name, String
          argument :specialties, [String]

          def resolve(**)
            perform(:hire_keeper, **)
          end
        end
      end
    end
  end
end
