# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Mutations
        class RunDays < BaseMutation
          type Types::RunDaysSummary, null: false

          argument :days, Integer

          def resolve(**)
            perform(:run_days, **)
          end
        end
      end
    end
  end
end
