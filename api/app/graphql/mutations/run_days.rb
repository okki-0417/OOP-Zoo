# frozen_string_literal: true

module Mutations
  class RunDays < BaseMutation
    type Types::RunDaysSummary, null: false

    argument :days, Integer

    def resolve(**)
      perform(:run_days, **)
    end
  end
end
