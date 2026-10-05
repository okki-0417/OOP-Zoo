# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Mutations
        class CleanEnclosure < BaseMutation
          type Types::Enclosure, null: false

          argument :enclosure_id, ID
          argument :keeper_id, ID

          def resolve(**)
            perform(:clean_enclosure, **)
          end
        end
      end
    end
  end
end
