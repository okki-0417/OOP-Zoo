# frozen_string_literal: true

module Mutations
  class RunDays < BaseMutation
    type Types::RunDaysSummary, null: false

    argument :days, Integer, validates: { numericality: { greater_than: 0, message: '日数は1以上でなければなりません' } }

    def resolve(days:)
      dead = Array.new(days) { ZooDay.current.run.casualties }.flatten
      { days:, total_deaths: dead.size, deaths_by_cause: dead.group_by(&:cause_of_death).transform_values(&:size) }
    end
  end
end
