# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Mutations
        class TransferAnimal < BaseMutation
          type Types::Animal, null: false

          argument :animal_id, ID
          argument :enclosure_id, ID

          def resolve(**)
            perform(:transfer_animal, **)
          end
        end
      end
    end
  end
end
