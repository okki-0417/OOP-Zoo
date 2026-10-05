# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Mutations
        class AcquireAnimal < BaseMutation
          type Types::Animal, null: false

          argument :species_code, String
          argument :name, String
          argument :sex, String

          def resolve(**)
            perform(:acquire_animal, **)
          end
        end
      end
    end
  end
end
