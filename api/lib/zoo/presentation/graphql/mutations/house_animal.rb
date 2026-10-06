# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Mutations
        class HouseAnimal < BaseMutation
          type Types::Enclosure, null: false

          argument :enclosure_id, ID
          argument :animal_id, ID

          def resolve(**)
            perform(:house_animal, **)
          end
        end
      end
    end
  end
end
