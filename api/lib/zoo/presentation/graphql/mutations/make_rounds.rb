# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Mutations
        class MakeRounds < BaseMutation
          type Types::Rounds, null: false

          argument :keeper_id, ID

          def resolve(**)
            perform(:make_rounds, **)
          end
        end
      end
    end
  end
end
