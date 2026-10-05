# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Mutations
        class SetAdmissionFee < BaseMutation
          type Types::Zoo, null: false

          argument :fee, Integer

          def resolve(**)
            perform(:set_admission_fee, **)
          end
        end
      end
    end
  end
end
